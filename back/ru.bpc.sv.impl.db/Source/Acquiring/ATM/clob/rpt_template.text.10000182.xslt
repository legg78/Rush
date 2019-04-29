<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="report">
        <xsl:text>ATM Event Notification Report (testing mode)</xsl:text>
        <xsl:text>&#10;terminal_number: </xsl:text><xsl:value-of select="terminal_number"/>
        <xsl:text>&#10;atm_address: </xsl:text><xsl:value-of select="atm_address"/>
        <xsl:text>&#10;event_type: </xsl:text><xsl:value-of select="event_type/code"/><xsl:text> (</xsl:text><xsl:value-of select="event_type/name"/><xsl:text>)</xsl:text>
        <xsl:text>&#10;connection_status: </xsl:text><xsl:value-of select="connection_status/previous"/>/<xsl:value-of select="connection_status/current"/>
        <xsl:text>&#10;card_reader_status: </xsl:text><xsl:value-of select="card_reader_status/previous"/>/<xsl:value-of select="card_reader_status/current"/>
        <xsl:text>&#10;rcpt_status: </xsl:text><xsl:value-of select="rcpt_status/previous"/>/<xsl:value-of select="rcpt_status/current"/>
        <xsl:text>&#10;rcpt_paper_status: </xsl:text><xsl:value-of select="rcpt_paper_status/previous"/>/<xsl:value-of select="rcpt_paper_status/current"/>
        <xsl:text>&#10;rcpt_ribbon_status: </xsl:text><xsl:value-of select="rcpt_ribbon_status/previous"/>/<xsl:value-of select="rcpt_ribbon_status/current"/>
        <xsl:text>&#10;rcpt_head_status: </xsl:text><xsl:value-of select="rcpt_head_status/previous"/>/<xsl:value-of select="rcpt_head_status/current"/>
        <xsl:text>&#10;rcpt_knife_status: </xsl:text><xsl:value-of select="rcpt_knife_status/previous"/>/<xsl:value-of select="rcpt_knife_status/current"/>
        <xsl:text>&#10;jrnl_status: </xsl:text><xsl:value-of select="jrnl_status/previous"/>/<xsl:value-of select="jrnl_status/current"/>
        <xsl:text>&#10;jrnl_paper_status: </xsl:text><xsl:value-of select="jrnl_paper_status/previous"/>/<xsl:value-of select="jrnl_paper_status/current"/>
        <xsl:text>&#10;jrnl_ribbon_status: </xsl:text><xsl:value-of select="jrnl_ribbon_status/previous"/>/<xsl:value-of select="jrnl_ribbon_status/current"/>
        <xsl:text>&#10;jrnl_head_status: </xsl:text><xsl:value-of select="jrnl_head_status/previous"/>/<xsl:value-of select="jrnl_head_status/current"/>
        <xsl:text>&#10;ejrnl_status: </xsl:text><xsl:value-of select="ejrnl_status/previous"/>/<xsl:value-of select="ejrnl_status/current"/>
        <xsl:text>&#10;ejrnl_space_status: </xsl:text><xsl:value-of select="ejrnl_space_status/previous"/>/<xsl:value-of select="ejrnl_space_status/current"/>
        <xsl:text>&#10;stmt_status: </xsl:text><xsl:value-of select="stmt_status/previous"/>/<xsl:value-of select="stmt_status/current"/>
        <xsl:text>&#10;stmt_paper_status: </xsl:text><xsl:value-of select="stmt_paper_status/previous"/>/<xsl:value-of select="stmt_paper_status/current"/>
        <xsl:text>&#10;stmt_ribbon_stat: </xsl:text><xsl:value-of select="stmt_ribbon_stat/previous"/>/<xsl:value-of select="stmt_ribbon_stat/current"/>
        <xsl:text>&#10;stmt_head_status: </xsl:text><xsl:value-of select="stmt_head_status/previous"/>/<xsl:value-of select="stmt_head_status/current"/>
        <xsl:text>&#10;stmt_knife_status: </xsl:text><xsl:value-of select="stmt_knife_status/previous"/>/<xsl:value-of select="stmt_knife_status/current"/>
        <xsl:text>&#10;stmt_capt_bin_status: </xsl:text><xsl:value-of select="stmt_capt_bin_status/previous"/>/<xsl:value-of select="stmt_capt_bin_status/current"/>
        <xsl:text>&#10;tod_clock_status: </xsl:text><xsl:value-of select="tod_clock_status/previous"/>/<xsl:value-of select="tod_clock_status/current"/>
        <xsl:text>&#10;depository_status: </xsl:text><xsl:value-of select="depository_status/previous"/>/<xsl:value-of select="depository_status/current"/>
        <xsl:text>&#10;night_safe_status: </xsl:text><xsl:value-of select="night_safe_status/previous"/>/<xsl:value-of select="night_safe_status/current"/>
        <xsl:text>&#10;encryptor_status: </xsl:text><xsl:value-of select="encryptor_status/previous"/>/<xsl:value-of select="encryptor_status/current"/>
        <xsl:text>&#10;tscreen_keyb_status: </xsl:text><xsl:value-of select="tscreen_keyb_status/previous"/>/<xsl:value-of select="tscreen_keyb_status/current"/>
        <xsl:text>&#10;voice_guidance_status: </xsl:text><xsl:value-of select="voice_guidance_status/previous"/>/<xsl:value-of select="voice_guidance_status/current"/>
        <xsl:text>&#10;camera_status: </xsl:text><xsl:value-of select="camera_status/previous"/>/<xsl:value-of select="camera_status/current"/>
        <xsl:text>&#10;bunch_acpt_status: </xsl:text><xsl:value-of select="bunch_acpt_status/previous"/>/<xsl:value-of select="bunch_acpt_status/current"/>
        <xsl:text>&#10;envelope_disp_status: </xsl:text><xsl:value-of select="envelope_disp_status/previous"/>/<xsl:value-of select="envelope_disp_status/current"/>
        <xsl:text>&#10;cheque_module_status: </xsl:text><xsl:value-of select="cheque_module_status/previous"/>/<xsl:value-of select="cheque_module_status/current"/>
        <xsl:text>&#10;barcode_reader_status: </xsl:text><xsl:value-of select="barcode_reader_status/previous"/>/<xsl:value-of select="barcode_reader_status/current"/>
        <xsl:text>&#10;coin_disp_status: </xsl:text><xsl:value-of select="coin_disp_status/previous"/>/<xsl:value-of select="coin_disp_status/current"/>
        <xsl:text>&#10;dispenser_status: </xsl:text><xsl:value-of select="dispenser_status/previous"/>/<xsl:value-of select="dispenser_status/current"/>
        <xsl:text>&#10;workflow_status: </xsl:text><xsl:value-of select="workflow_status/previous"/>/<xsl:value-of select="workflow_status/current"/>
        <xsl:text>&#10;service_status: </xsl:text><xsl:value-of select="service_status/previous"/>/<xsl:value-of select="service_status/current"/>
        <xsl:for-each select="dispenser">
            <xsl:text>&#10;dispenser: </xsl:text>
                <xsl:text>disp_number=</xsl:text><xsl:value-of select="disp_number"/>
                <xsl:text>, face_value=</xsl:text><xsl:value-of select="face_value"/>
                <xsl:text>, currency=</xsl:text><xsl:value-of select="currency"/>
                <xsl:text>, dispenser_type=</xsl:text><xsl:value-of select="dispenser_type/code"/>
                <xsl:text>, note_loaded=</xsl:text><xsl:value-of select="note_loaded"/>
                <xsl:text>, note_dispensed=</xsl:text><xsl:value-of select="note_dispensed"/>
                <xsl:text>, note_remained=</xsl:text><xsl:value-of select="note_remained"/>
                <xsl:text>, note_rejected=</xsl:text><xsl:value-of select="note_rejected"/>
                <xsl:text>, cassette_status=</xsl:text><xsl:value-of select="cassette_status"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>