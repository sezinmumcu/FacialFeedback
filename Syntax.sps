* Encoding: UTF-8.

*Check for missing values and ranges by making a frequency table including all variables. There are no missing values and all variables are in the predetermined range.
FREQUENCIES VARIABLES=Condition Sexe Age AmusedClip1 AmusedClip2 AmusedClip3 AmusedClip4 AmusedClip5 AmusedClip6 AmusedClip7 AmusedClip8 AmusedClip9 AmusedClip10 MoodPre AttentionCheck1 AttentionCheck2
  /STATISTICS=STDDEV RANGE MINIMUM MAXIMUM MEAN MEDIAN MODE
  /ORDER=ANALYSIS.

*Compute the mean of AttentionCheck1 and AttentionCheck2.
DATASET ACTIVATE DataSet1.
COMPUTE AttentionCheckMean=MEAN(AttentionCheck1,AttentionCheck2).
EXECUTE.

*Select cases where AttentionCheckMean > 0. Filter unselected cases. Participants with ID 11, 21, 27, 31, 89, 105, 113 are 0 scorers on both AttentionCheck1 and AttentionCheck2.
USE ALL.
COMPUTE filter_$=(AttentionCheckMean > 0  ).
VARIABLE LABELS filter_$ 'AttentionCheckMean > 0   (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).FILTER BY filter_$.
EXECUTE.

*Delete 0 scorers on AttentionCheck1 and AttentionCheck2.
FILTER OFF.
USE ALL.
SELECT IF (AttentionCheckMean > 0).
EXECUTE.

*Compute z-scores for AmusedClip1-7.
DESCRIPTIVES VARIABLES=AmusedClip1 AmusedClip2 AmusedClip3 AmusedClip4 AmusedClip5 AmusedClip6 AmusedClip7 AmusedClip8 AmusedClip9
  /SAVE
  /STATISTICS=MEAN STDDEV MIN MAX.

*To check for outliers, make a frequency table of zAmusedclip1-7. Check the maximum and minimum values. zAmusedclip7 has data points outside the range (-3, 3).
FREQUENCIES VARIABLES=ZAmusedClip1 ZAmusedClip2 ZAmusedClip3 ZAmusedClip4 ZAmusedClip5 ZAmusedClip6  ZAmusedClip7 ZAmusedClip8 ZAmusedClip9
  /STATISTICS=STDDEV RANGE MINIMUM MAXIMUM MEAN MEDIAN MODE
  /ORDER=ANALYSIS.



*Filter cases where zAmusedclip7 is outside the range (-3, 3). Participants with ID 100 and 148 are outside the range.
USE ALL.
COMPUTE filter_$=(ZAmusedClip7 < 3  &  ZAmusedClip7 > -3).
VARIABLE LABELS filter_$ 'ZAmusedClip7 < 3  &  ZAmusedClip7 > -3 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.


*Turn off the filter for now to include outliers.
FILTER OFF.
USE ALL.
EXECUTE.


*Compute the mean of AmusedClip1-9. 
DATASET ACTIVATE DataSet1.
COMPUTE AmusedClipMean=MEAN(AmusedClip1,AmusedClip2,AmusedClip3,AmusedClip4,AmusedClip5,AmusedClip6,AmusedClip7,AmusedClip8,AmusedClip9).
EXECUTE.

*Calculate Cook's d to check for influential cases. Check maximum Cook’s d.
REGRESSION 
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT AmusedClipMean
  /METHOD=ENTER Condition
  /SAVE COOK.


*Filter influential cases, as indicated by Cook's d > 0.028. These belong to participants with ID 32, 46, 122. 147, 151.
DATASET ACTIVATE DataSet1.
USE ALL.
COMPUTE filter_$=(COO_1 < 0.028).
VARIABLE LABELS filter_$ 'COO_1 < 0.028 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

*Turn off the filter for now to include influential cases.
FILTER OFF.
USE ALL.
EXECUTE.


*Check for assumption of unequal variances via Shapiro-Wilk test.
EXAMINE VARIABLES=AmusedClipMean
  /PLOT BOXPLOT STEMLEAF NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Conduct ANOVA [dependent list: AmusedClipMean; factor: Condition]. Check for assumption of homogeneity via Levene's test.
ONEWAY AmusedClipMean BY Condition
   /ES=OVERALL
  /PLOT MEANS
  /STATISTICS HOMOGENEITY 
    /MISSING ANALYSIS
  /CRITERIA=CILEVEL(0.95).

*Delete outliers listwise.
FILTER OFF.
USE ALL.
SELECT IF (ZAmusedClip7 < 3  &  ZAmusedClip7 > -3).
EXECUTE.

*Delete influential cases listwise.
FILTER OFF.
USE ALL.
SELECT IF (COO_1 < 0.028).
EXECUTE.

*Check for assumption of unequal variances via Shapiro-Wilk test again after removing outliers and influential cases.
EXAMINE VARIABLES=AmusedClipMean
  /PLOT BOXPLOT STEMLEAF NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Conduct ANOVA again after removing outliers. 
ONEWAY AmusedClipMean BY Condition
   /ES=OVERALL
  /PLOT MEANS
  /STATISTICS HOMOGENEITY 
  /MISSING ANALYSIS
  /CRITERIA=CILEVEL(0.95).

*Conduct ANCOVA [between-subjects factor: Condition; covariate: MoodPre].
UNIANOVA AmusedClipMean BY Condition WITH MoodPre
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PRINT ETASQ DESCRIPTIVE
   /PLOT=PROFILE(Condition) TYPE=LINE ERRORBAR=NO MEANREFERENCE=NO YAXIS=AUTO
  /CRITERIA=ALPHA(.05)
  /DESIGN=MoodPre Condition.




