package ru.bpc.sv.ws.cup.jms;

import com.bpcbt.sv.pack.Pack;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.log4j.Logger;
import org.w3c.dom.Element;
import org.w3c.dom.Text;
import ru.bpc.sv.ws.cup.utils.XmlUtils;

import javax.jms.*;
import java.util.Timer;
import java.util.TimerTask;

public class JmsQueueService implements MessageListener {
	protected static Logger logger = Logger.getLogger("PROCESSES");

	public interface JmsQueueListener {
		void onReceiveData(String fileName, String svxp, long recordsNum, boolean finalPackage);

		void onError(Exception ex);
	}

	private static final long WAIT_MESSAGE_SECONDS = 20;

	private String mqUrl;
	private String queue;
	private JmsQueueListener listener;
	private int cnt;
	private Connection connection;
	private Session session;
	private MessageConsumer consumer;

	private TimerTask abortTask;
	private Timer timer = new Timer(true);
	private boolean asIs = false;

	public JmsQueueService(String mqUrl, String queue, JmsQueueListener listener) {
		this.mqUrl = mqUrl;
		this.queue = queue;
		this.listener = listener;
	}

	public JmsQueueService(String mqUrl, String queue, JmsQueueListener listener, boolean asIs) {
		this.mqUrl = mqUrl;
		this.queue = queue;
		this.listener = listener;
		this.asIs = asIs;
	}

	public void start() throws Exception {
		cnt = 0;
		ConnectionFactory connectionFactory = new ActiveMQConnectionFactory(mqUrl);
		connection = connectionFactory.createConnection();
		connection.start();
		session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
		consumer = session.createConsumer(session.createQueue(queue));
		consumer.setMessageListener(this);
	}

	public void stop() {
		try {
			if (consumer != null) {
				consumer.close();
			}
		} catch (JMSException e) {
			logger.error("Error on closing JMS consumer: " + e.getMessage(), e);
		}
		try {
			if (session != null) {
				session.close();
			}
		} catch (JMSException e) {
			logger.error("Error on closing JMS session: " + e.getMessage(), e);
		}
		try {
			if (connection != null) {
				connection.close();
			}
		} catch (JMSException e) {
			logger.error("Error on closing JMS connection: " + e.getMessage(), e);
		}
		if (timer != null) {
			timer.cancel();
		}
	}

	@Override
	public void onMessage(Message message) {
		try {
			if (message instanceof TextMessage) {
				//cancel abort task
				if (abortTask != null) {
					abortTask.cancel();
				}
				final TextMessage m = (TextMessage) message;
				boolean last = false;
				if (asIs) {
					listener.onReceiveData(null, m.getText(), m.getLongProperty("total"), false);
				} else {
					Pack pack = (Pack) XmlUtils.toXMLObject(m.getText(), Pack.class);
					String bodyString;
					String svxp;
					Object body = pack.getBody();
					if (body instanceof String) {
						bodyString = (String) body;
					} else if (body instanceof Element && ((Element) body).getFirstChild() instanceof Text) {
						bodyString = ((Text)((Element) body).getFirstChild()).getWholeText();
					} else {
						if (body == null) {
							throw new RuntimeException("Package body is null");
						} else {
							throw new RuntimeException("Could not process message body of type " + body.getClass().getName());
						}
					}
					svxp = bodyString.replaceAll("(\\<\\!\\[CDATA\\[|\\]\\]\\>)", "");
					cnt++;
					last = cnt == pack.getHeader().getPacksTotal();
					listener.onReceiveData(createFileName(pack.getHeader().getFileName(), pack.getHeader().getNumber(),
							pack.getHeader().getPacksTotal()), svxp, pack.getHeader().getRecordsNumber(), last);
				}
				//schedule task to abort transmission when there is no message for long time
				if (!last) {
					abortTask = new TimerTask() {
						@Override
						public void run() {
							listener.onError(new Exception("Not received message for long time"));
						}
					};
					timer.schedule(abortTask, WAIT_MESSAGE_SECONDS * 1000);
				}
			}
		} catch (Exception ex) {
			listener.onError(ex);
			throw new RuntimeException(ex);
		}
	}

	private String createFileName(String fileName, long currentPackNum, long totalPackNum) {
		StringBuilder sb = new StringBuilder();
		sb.append(currentPackNum);
		int digits = (int) Math.floor(Math.log10(totalPackNum)) + 1;
		while (sb.length() < digits) {
			sb.insert(0, '0');
		}
		sb.insert(0, fileName);
		return sb.toString();
	}
}
