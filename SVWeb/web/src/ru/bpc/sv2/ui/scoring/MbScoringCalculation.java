package ru.bpc.sv2.ui.scoring;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.ScoringDao;
import ru.bpc.sv2.scoring.*;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbScoringCalculation")
public class MbScoringCalculation extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("SCORING");

    private List<SelectItem> evaluations;
    private List<ScoringCriteriaValues> criterias;
    private Long evaluationId;
    private Integer instId;
    private String grade;
    private Long totalScore;
    private Long totalMaxScore;

    public MbScoringCalculation() {}

    private ScoringDao scoringDao = new ScoringDao();

    @Override
    public void clearFilter() {
        instId = null;
        evaluationId = null;
        evaluations = null;
        criterias = null;
        grade = null;
        totalScore = 0L;
        totalMaxScore = 0L;
    }

    public List<SelectItem> getEvaluations() {
        return evaluations;
    }
    public void setEvaluations(List<SelectItem> evaluations) {
        this.evaluations = evaluations;
    }

    public List<ScoringCriteriaValues> getCriterias() {
        return criterias;
    }
    public void setCriterias(List<ScoringCriteriaValues> criterias) {
        this.criterias = criterias;
    }

    public Long getEvaluationId() {
        return evaluationId;
    }
    public void setEvaluationId(Long evaluationId) {
        this.evaluationId = evaluationId;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public String getGrade() {
        return grade;
    }
    public void setGrade(String grade) {
        this.grade = grade;
    }

    public Long getTotalScore() {
        return totalScore;
    }
    public void setTotalScore(Long totalScore) {
        this.totalScore = totalScore;
    }

    public Long getTotalMaxScore() {
        return totalMaxScore;
    }
    public void setTotalMaxScore(Long totalMaxScore) {
        this.totalMaxScore = totalMaxScore;
    }

    public List<SelectItem> getInstitutions() {
        return getDictUtils().getLov(LovConstants.INSTITUTIONS);
    }

    public void loadEvaluations() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));
        if (instId != null) {
            filters.add(Filter.create("instId", instId));
        }
        List<ScoringScheme> schemes = scoringDao.getScoringSchemes(userSessionId, new SelectionParams(0, 1000, filters));
        if (schemes != null) {
            evaluations = new ArrayList<SelectItem>(schemes.size());
            for (ScoringScheme scheme : schemes) {
                evaluations.add(new SelectItem(scheme.getId(), scheme.getName()));
            }
        }
    }

    public void loadCriterias() {
        if (evaluationId != null) {
            filters = new ArrayList<Filter>();
            filters.add(Filter.create("lang", userLang));
            filters.add(Filter.create("schemeId", evaluationId));
            criterias = getCriteriaValues(userSessionId, new SelectionParams(0, 1000, filters));
        } else {
            criterias = null;
        }
    }

    public void calculate() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));
        filters.add(Filter.create("schemeId", evaluationId));
        List<SortElement> sortElements = new ArrayList<SortElement>(1);
        sortElements.add(new SortElement("score", SortElement.Direction.DESC));
        List<ScoringGrade> grades = scoringDao.getScoringGrades(userSessionId, new SelectionParams(0, 1000, filters, sortElements));

        totalScore = 0L;
        grade = null;
        if (criterias != null) {
            for (ScoringCriteriaValues criteria : criterias) {
                totalScore += criteria.getScore();
            }
            if (grades != null && grades.size() > 0) {
                for (ScoringGrade grade : grades) {
                    if (totalScore >= grade.getTotalScore()) {
                        this.grade = grade.getGrade();
                        break;
                    }
                }
            } else {
                FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Scr", "grades_missing_error"));
            }
            if (grade == null) {
                grade = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Scr", "grade_not_defined");
            }
        }
    }

    private List<ScoringCriteriaValues> getCriteriaValues(Long userSessionId, SelectionParams params) {
        List<ScoringCriteriaValues> out = new ArrayList<ScoringCriteriaValues>();
        List<ScoringCriteria> criterias = scoringDao.getScoringCriterias(userSessionId, params);
        List<Filter> filters = new ArrayList<Filter>(params.getFilters().length);
        for (Filter filter : params.getFilters()) {
            if ("lang".equals(filter.getElement())) {
                filters.add(filter);
            }
        }
        for (ScoringCriteria criteria : criterias) {
            if (filters.size() == 1) {
                filters.add(Filter.create("criteriaId", criteria.getId()));
            } else {
                filters.get(1).setValue(criteria.getId());
            }
            params.setFilters(filters);
            out.add(new ScoringCriteriaValues(criteria, scoringDao.getValues(userSessionId, params)));
            totalMaxScore += out.get(out.size()-1).getMaxScore();
        }
        return out;
    }
}
