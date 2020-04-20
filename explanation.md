### Summary (Written April 5 2020)

This calculator uses estimates for the sensitivity and specificity of RT-PCR testing for SARS-CoV-2, as well as estimates for the prevalence of SARS-CoV-2 among asymptomatic individuals in the community to assess the risk of exposure to SARS-CoV-2 during airway management of an individual with a recently negative SARS-CoV-2 test. A low probability (defined by the operator or healthcare system, not the authors) *could* justify the use of droplet (rather than airborne) precautions during airway management of asymptomatic patients.

### SARS-CoV-2 RT-PCR

The characteristics of tests being used to detect viral RNA with PCR are evolving. It is widely accepted that viral PCR tests have very high *specificity*, but estimation of their clinical *sensitivity* requires datasets that do not, as of the publication of the letter accompanying this calculator, exist. The most important piece of reference information is a 'gold standard' against which to compare RT-PCR testing of a specific anatomic site. One clinical report, [published in JAMA](https://jamanetwork.com/journals/jama/fullarticle/2762997), reported that the 'clinical sensitivity' of nasal swabs could be as low as 63%, though the sample size was very low. The standard of comparison in this report was not well defined, and the testing methodology used differs slightly than that used in the US.

As a result, the default sensitivity in our calculator is 65%, to demonstrate a 'worst case scenario' and the implications for NPV.

### COVID-19 Prevalence Among Asymptomatic Individuals

To have high confidence in the SARS-CoV-2 test result, it is necessary to understand the test’s negative predictive value: i.e., probability that the disease  is *not present* when the test is negative. NPV is influenced by factors beyond the intrinsic performance characteristics of the test and requires knowledge of the prevalence of SARS-CoV-2 in the community. The mathematical inverse of NPV (1 / NPV) is the post-test probability of disease.

At this stage in the pandemic, little is known about the prevalence of SARS-CoV-2 among asymptomatic individuals in the population. Our default assumption (0.6%) is informed by [this report from Iceland](https://www.nejm.org/doi/full/10.1056/NEJMoa2006100).

### Calculation Methodology

Our calculator allows both a simplified calculation for NPV (utilizing sensitivity, specificity, and prevalence of disease,  parameterized as percentages), but also allows the user to specify the bounds of their uncertainty for these values.

The methodology we have selected for modeling this uncertainty uses the [PERT distribution](https://en.wikipedia.org/wiki/PERT_distribution). Each component of negative predictive value is conceived of as a Beta distributed random variable, and the user specifies the values they think the parameter *most likely* takes, as well as the *minimum* and *maximum* values that they think the parameter *could* take. 10,000 draws from this PERT distribution are performed for each component of the NPV calculation, and a distribution of NPV outcomes is created from each set of draws.

### User Survey

We would be very grateful if you would consider completing [this completely anonymous survey](https://forms.gle/5gFSvFKHPsfrAamp8) regarding your opinions about acceptable risks of exposure to SARS-CoV-2 during airway management. *Please only complete the survey one time.*

### Contributions

This calculator was developed by : 

- Dusting Long MD
- Jacob Sunshine MD MS
- Wil Van Cleve MD MPH

All of the developers are faculty in the Department of Anesthesiology and Pain Medicine, University of Washington, Seattle WA.

### Code

All code used in this calculator [is available for download and review](https://github.com/wilvancleve/covid-airway-npv). The authors welcome comments via GitHub.
