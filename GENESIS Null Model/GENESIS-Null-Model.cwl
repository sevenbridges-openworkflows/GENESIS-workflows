{
  "class": "Workflow",
  "cwlVersion": "v1.1",
  "doc": "**Null Model** workflow fits the regression or mixed effects model under the null hypothesis of no genotype effects. i.e., The outcome variable is regressed on the specified fixed effect covariates and random effects. The output of this null model is then used in the association tests.\n\nQuantitative and binary outcomes are both supported. Set parameter **family** to gaussian, binomial or poisson depending on the outcome type. Fixed effect covariates from the **Phenotype file** are specified using the **Covariates** parameter, and ancestry principal components can be included as fixed effects using the **PCA Files** and **Number of PCs to include as covariates** parameters. A kinship matrix (KM) or genetic relationship matrix (GRM) can be provided using the **Relatedness matrix file** parameter to account for genetic similarity among samples as a random effect. \n\nWhen no **Relatedness matrix file** is provided, standard linear regression is used if the parameter **family** is set to gaussian, logistic regression is used if the parameter **family** is set to binomial and poisson regression is used in case when **family** is set to poisson. When **Relatedness matrix file** is provided, a linear mixed model (LMM) is fit if **family** is set to gaussian, or a generalized linear mixed model (GLMM) is fit using the [GMMAT method](https://doi.org/10.1016/j.ajhg.2016.02.012) if **family** is set to binomial or poisson. For either the LMM or GLMM, the [AI-REML algorithm](https://doi.org/10.1111/jbg.12398) is used to estimate the variance components and fixed effects parameters.\n \nWhen samples come from multiple groups (e.g., study or ancestry group), it is common to observe different variances by group for quantitative traits. It is recommended to allow the null model to fit heterogeneous residual variances by group using the parameter group_var. This often provides better control of false positives in subsequent association testing. Note that this only applies when **family** is set to gaussian.\n\nRank-based inverse Normal transformation is supported for quantitative outcomes via the inverse_normal parameter. This parameter is TRUE by default. When **inverse normal** parameter is set to TRUE, (1) the null model is fit using the original outcome values, (2) the marginal residuals are rank-based inverse Normal transformed, and (3) the null model is fit again using the transformed residuals as the outcome; fixed effects and random effects are included both times the null model is fit. It has been shown that this fully adjusted two-stage procedure provides better false positive control and power in association tests than simply inverse Normalizing the outcome variable prior to analysis [(**reference**)](https://doi.org/10.1002/gepi.22188).\n\nThis workflow utilizes the *fitNullModel* function from the [GENESIS](doi.org/10.1093/bioinformatics/btz567) software.\n\nWorkflow consists of two steps. First step fits the null model, and the second one generates reports based on data. Reports are available both in RMD and HTML format. If **inverse normal** is TRUE, reports are generated for the model both before and after the transformation.\nReports contain the following information: Config info, phenotype distributions, covariate effect size estimates, marginal residuals, adjusted phenotype values and session information.\n\n### Common use cases:\nThis workflow is the first step in association testing. This workflow fits the null model and produces several files which are used in the association testing workflows:\n* Null model file which contains adjusted outcome values, the model matrix, the estimated covariance structure, and other parameters required for downstream association testing. This file will be input in association testing workflows.\n* Phenotype file which is a subset of the provided phenotype file, containing only the outcome and covariates used in fitting null model.\n* *Reportonly* null model file which is used to generate the report for the association test\n\n\nThis workflow can be used for trait heritability estimation.\n\nIndividual genetic variants or groups of genetic variants can be directly tested for association with this workflow by including them as fixed effect covariates in the model (via the **Conditional Variant File** parameter). This would be extremely inefficient genome-wide, but is useful for follow-up analyses testing variants of interest.\n\n\n### Common issues and important notes:\n* If **PCA File** is not provided, the **Number of PCs to include as covariates** parameter **must** be set to 0.\n\n* **PCA File** must be an RData object output from the *pcair* function in the GENESIS package.\n\n* The null model job can be very computationally demanding in large samples (e.g. > 20K). GENESIS supports using sparse representations of matrices in the **Relatedness matrix file** via the R Matrix package, and this can substantially reduce memory usage and CPU time.\n\n### Performance Benchmarking\n\nIn the following table you can find estimates of running time and cost on spot instances. \n      \n| Samples &nbsp; &nbsp;| Relatedness matrix &nbsp; &nbsp; | Instance type &nbsp; &nbsp;| Instance &nbsp;  &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;  &nbsp; &nbsp;&nbsp; &nbsp;| Time   &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | Cost  |\n| ------- | --------------------- | ---------------- | -------------- | ----------- | ----- |\n| 2.5K    | w/o                   | Spot             | c4xlarge       | 5 min       | 0.01$ |\n| 10K     | w/o                   | Spot             | r4.8xlarge     | 6 min       | 0.06$ |\n| 36K     | w/o                   | Spot             | r4.8xlarge     | 7 min       | 0.06$ |\n| 50K     | w/o                   | Spot             | r4.8xlarge     | 7 min       | 0.07$ |\n| 2.5K    | Sparse                | Spot             | c4xlarge       | 5 min       | 0.01$ |\n| 10K     | Sparse                | Spot             | r4.8xlarge     | 8 min       | 0.06$ |\n| 36K     | Sparse                | Spot             | r4.8xlarge     | 40 min      | 0.40$ |\n| 50K     | Sparse                | Spot             | r4.8xlarge     | 50 min      | 0.50$ |\n| 2.5K    | Dense                 | Spot             | c4.xlarge      | 5 min       | 0.01$ |\n| 10K     | Dense                 | Spot             | c4.2xlarge     | 13 min      | 0.06$ |\n| 36K     | Dense                 | Spot             | r4.4xlarge     | 55 min      | 0.45$ |\n| 50K     | Dense                 | Spot             | r4.8xlarge     | 2 h         | 1.50$ |\n| 2.5K    | w/o                   | Preemtible       | n1-standard-4  | 5 min       | 0.01$ |\n| 10K     | w/o                   | Preemtible       | n1-standard-32 | 6 min       | 0.05$ |\n| 36K     | w/o                   | Preemtible       | n1-hihgmem-32  | 8 min       | 0.06$ |\n| 50K     | w/o                   | Preemtible       | n1-hihgmem-32  | 7 min       | 0.06$ |\n| 2.5K    | Sparse                | Preemtible       | n1-standard-4  | 5 min       | 0.01$ |\n| 10K     | Sparse                | Preemtible       | n1-hihgmem-32  | 7 min       | 0.06$ |\n| 36K     | Sparse                | Preemtible       | n1-hihgmem-32  | 40 min      | 0.30$ |\n| 50K     | Sparse                | Preemtible       | n1-hihgmem-32  | 50 min      | 0.45$ |\n| 2.5K    | Dense                 | Preemtible       | n1-highcpu-8   | 10 min      | 0.01$ |\n| 10K     | Dense                 | Preemtible       | n1-highcpu-16  | 12 min      | 0.04$ |\n| 36K     | Dense                 | Preemtible       | n1-standard-32 | 43 min      | 1$    |\n| 50K     | Dense                 | Preemtible       | n1-standard-96 | 2 h, 30 min | 12$   |\n\n\n*Cost shown here were obtained with **spot/preemptible instances** enabled. Visit the [Knowledge Center](https://docs.sevenbridges.com/docs/about-spot-instances) for more details.*",
  "label": "Null Model",
  "$namespaces": {
    "sbg": "https://sevenbridges.com"
  },
  "inputs": [
    {
      "id": "n_pcs",
      "type": "int?",
      "label": "Number of PCs to include as covariates",
      "doc": "Number of PCs from PCA file to include as covariates.",
      "sbg:toolDefaultValue": "0",
      "sbg:x": -598.6190185546875,
      "sbg:y": 372.05194091796875
    },
    {
      "id": "sample_include_file",
      "sbg:fileTypes": "RDATA",
      "type": "File?",
      "label": "Sample include file",
      "doc": "RData file with a vector of sample.id to include. If not provided, all samples in the Phenotype file will be included in the analysis.",
      "sbg:x": -490.25,
      "sbg:y": -666.1776123046875
    },
    {
      "id": "phenotype_file",
      "sbg:fileTypes": "RDATA",
      "type": "File",
      "label": "Phenotype file",
      "doc": "RData file with an AnnotatedDataFrame of phenotypes and covariates. Sample identifiers must be in column named \u201csample.id\u201d.",
      "sbg:x": -597.75,
      "sbg:y": -621.5
    },
    {
      "id": "pca_file",
      "sbg:fileTypes": "RDATA",
      "type": "File?",
      "label": "PCA File",
      "doc": "RData file containing principal components for ancestry adjustment. R object type may be \u201cpcair\u201d, data.frame, or matrix. Row names must contain sample identifiers.",
      "sbg:x": -598.75,
      "sbg:y": -489.25
    },
    {
      "id": "output_prefix",
      "type": "string?",
      "label": "Output prefix",
      "doc": "Base for all output file names. By default it is null_model.",
      "sbg:x": -485.25,
      "sbg:y": -441.75
    },
    {
      "id": "cpu",
      "type": "int?",
      "label": "CPU",
      "doc": "Number of CPUs to use per job.",
      "sbg:toolDefaultValue": "1",
      "sbg:x": -530.887451171875,
      "sbg:y": 457.2684020996094
    },
    {
      "id": "covars",
      "type": "string[]?",
      "label": "Covariates",
      "doc": "Names of columns in Phenotype file containing covariates.",
      "sbg:x": -401.9177551269531,
      "sbg:y": 601.9609985351562
    },
    {
      "id": "inverse_normal",
      "type": [
        "null",
        {
          "type": "enum",
          "symbols": [
            "TRUE",
            "FALSE"
          ],
          "name": "inverse_normal"
        }
      ],
      "label": "Two stage model",
      "doc": "TRUE if a two-stage model should be implemented. Stage 1: a null model is fit using the original outcome variable. Stage 2: a second null model is fit using the inverse-normal transformed residuals from Stage 1 as the outcome variable. When FALSE, only the Stage 1 model is fit.  Only applies when Family is \u201cgaussian\u201d.",
      "sbg:toolDefaultValue": "TRUE",
      "sbg:x": -710.1770629882812,
      "sbg:y": 173.76121520996094
    },
    {
      "id": "outcome",
      "type": "string",
      "label": "Outcome",
      "doc": "Name of column in Phenotype file containing outcome variable.",
      "sbg:x": -744.6608276367188,
      "sbg:y": 56.6402587890625
    },
    {
      "id": "rescale_variance",
      "type": [
        "null",
        {
          "type": "enum",
          "symbols": [
            "marginal",
            "varcomp",
            "none"
          ],
          "name": "rescale_variance"
        }
      ],
      "label": "Rescale residuals",
      "doc": "Applies only if Two stage model is TRUE. Controls whether to rescale the inverse-normal transformed residuals before fitting the Stage 2 null model, restoring the values to their original scale before the transform. \u201cMarginal\u201d rescales by the standard deviation of the marginal residuals from the Stage 1 model. \u201cVarcomp\u201d rescales by an estimate of the standard deviation based on the Stage 1 model variance component estimates; this can only be used if Norm by group is TRUE. \u201cNone\u201d does not rescale.",
      "sbg:toolDefaultValue": "marginal",
      "sbg:x": -739.3484497070312,
      "sbg:y": -190.6490020751953
    },
    {
      "id": "group_var",
      "type": "string?",
      "label": "Group variate",
      "doc": "Name of column in Phenotype file providing groupings for heterogeneous residual error variances in the model. Only applies when Family is \u201cgaussian\u201d.",
      "sbg:x": -647.8939819335938,
      "sbg:y": 273.9382629394531
    },
    {
      "id": "conditional_variant_file",
      "sbg:fileTypes": "RDATA",
      "type": "File?",
      "label": "Conditional Variant File",
      "doc": "RData file with a data.frame of identifiers for variants to be included as covariates for conditional analysis. Columns should include \u201cchromosome\u201d and \u201cvariant.id\u201d that match the variant.id in the GDS files. The alternate allele dosage of these variants will be included as covariates in the analysis.",
      "sbg:x": -466,
      "sbg:y": 527.7529907226562
    },
    {
      "id": "relatedness_matrix_file",
      "sbg:fileTypes": "GDS, RDATA",
      "type": "File?",
      "label": "Relatedness matrix file",
      "doc": "RData or GDS file with a kinship matrix or genetic relatedness matrix (GRM). For RData files, R object type may be \u201cmatrix\u201d or \u201cMatrix\u201d. For very large sample sizes, a block diagonal sparse Matrix object from the \u201cMatrix\u201d package is recommended.",
      "sbg:x": -723.1589965820312,
      "sbg:y": -545.7281494140625
    },
    {
      "id": "gds_files",
      "sbg:fileTypes": "GDS",
      "type": "File[]?",
      "label": "GDS Files",
      "doc": "List of gds files with genotype data for variants to be included as covariates for conditional analysis. Only required if Conditional Variant file is specified.",
      "sbg:x": -773.5831298828125,
      "sbg:y": -57.84101486206055
    },
    {
      "id": "norm_bygroup",
      "type": [
        "null",
        {
          "type": "enum",
          "symbols": [
            "TRUE",
            "FALSE"
          ],
          "name": "norm_bygroup"
        }
      ],
      "label": "Norm by group",
      "doc": "Applies only if Two stage model is TRUE and Group variate is provided. If TRUE,the inverse-normal transformation (and rescaling) is done on each group separately. If FALSE, this is done on all samples jointly.",
      "sbg:toolDefaultValue": "FALSE",
      "sbg:x": -171.19671630859375,
      "sbg:y": 693.8524780273438
    },
    {
      "id": "family",
      "type": {
        "type": "enum",
        "symbols": [
          "gaussian",
          "poisson",
          "binomial"
        ],
        "name": "family"
      },
      "label": "Family",
      "doc": "The distribution used to fit the model. Select \u201cgaussian\u201d for continuous outcomes, \u201cbinomial\u201d for binary or case/control outcomes, or \u201cpoisson\u201d for count outcomes.",
      "sbg:x": -220.80503845214844,
      "sbg:y": 532.3207397460938
    },
    {
      "id": "n_categories_boxplot",
      "type": "int?",
      "label": "Number of categories in boxplot",
      "doc": "If a covariate has fewer than the specified value, boxplots will be used instead of scatter plots for that covariate in the null model report.",
      "sbg:x": 221.18121337890625,
      "sbg:y": 235.75128173828125
    }
  ],
  "outputs": [
    {
      "id": "null_model_phenotypes",
      "outputSource": [
        "null_model_r/null_model_phenotypes"
      ],
      "sbg:fileTypes": "RDATA",
      "type": "File?",
      "label": "Null model Phenotypes file",
      "doc": "Phenotype file containing all covariates used in the model. This file should be used as the \u201cPhenotype file\u201d input for the GENESIS association testing workflows.",
      "sbg:x": 461.51287841796875,
      "sbg:y": 53.166748046875
    },
    {
      "id": "rmd_files",
      "outputSource": [
        "null_model_report/rmd_files"
      ],
      "sbg:fileTypes": "Rmd",
      "type": "File[]?",
      "label": "Rmd files",
      "doc": "R markdown files used to generate the HTML reports.",
      "sbg:x": 774.503173828125,
      "sbg:y": -378.1446533203125
    },
    {
      "id": "html_reports",
      "outputSource": [
        "null_model_report/html_reports"
      ],
      "sbg:fileTypes": "html",
      "type": "File[]?",
      "label": "HTML Reports",
      "sbg:x": 784.3648071289062,
      "sbg:y": -109
    },
    {
      "id": "null_model_output",
      "outputSource": [
        "null_model_r/null_model_output"
      ],
      "type": "File[]?",
      "label": "Null model file",
      "sbg:x": 465.3710632324219,
      "sbg:y": 341.66351318359375
    }
  ],
  "steps": [
    {
      "id": "null_model_r",
      "in": [
        {
          "id": "outcome",
          "source": "outcome"
        },
        {
          "id": "phenotype_file",
          "source": "phenotype_file"
        },
        {
          "id": "gds_files",
          "source": [
            "gds_files"
          ]
        },
        {
          "id": "pca_file",
          "source": "pca_file"
        },
        {
          "id": "relatedness_matrix_file",
          "source": "relatedness_matrix_file"
        },
        {
          "id": "family",
          "source": "family"
        },
        {
          "id": "conditional_variant_file",
          "source": "conditional_variant_file"
        },
        {
          "id": "covars",
          "source": [
            "covars"
          ]
        },
        {
          "id": "group_var",
          "source": "group_var"
        },
        {
          "id": "inverse_normal",
          "source": "inverse_normal"
        },
        {
          "id": "n_pcs",
          "source": "n_pcs"
        },
        {
          "id": "rescale_variance",
          "source": "rescale_variance"
        },
        {
          "id": "sample_include_file",
          "source": "sample_include_file"
        },
        {
          "id": "cpu",
          "source": "cpu"
        },
        {
          "id": "output_prefix",
          "source": "output_prefix"
        },
        {
          "id": "norm_bygroup",
          "source": "norm_bygroup"
        }
      ],
      "out": [
        {
          "id": "configs"
        },
        {
          "id": "null_model_phenotypes"
        },
        {
          "id": "null_model_files"
        },
        {
          "id": "null_model_params"
        },
        {
          "id": "null_model_output"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-toolkit-demo/null-model-r/38",
        "baseCommand": [],
        "inputs": [
          {
            "sbg:category": "Configs",
            "id": "outcome",
            "type": "string",
            "label": "Outcome",
            "doc": "Name of column in Phenotype File containing outcome variable."
          },
          {
            "sbg:category": "Categories",
            "id": "phenotype_file",
            "type": "File",
            "label": "Phenotype file",
            "doc": "RData file with AnnotatedDataFrame of phenotypes.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "sbg:altPrefix": "GDS file.",
            "sbg:category": "Configs",
            "id": "gds_files",
            "type": "File[]?",
            "label": "GDS Files",
            "doc": "List of gds files. Required if conditional_variant_file is specified.",
            "sbg:fileTypes": "GDS"
          },
          {
            "sbg:category": "Configs",
            "id": "pca_file",
            "type": "File?",
            "label": "PCA File",
            "doc": "RData file with PCA results created by PC-AiR.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "sbg:category": "Categories",
            "id": "relatedness_matrix_file",
            "type": "File?",
            "label": "Relatedness matrix file",
            "doc": "RData or GDS file with a kinship matrix or GRM.",
            "sbg:fileTypes": "GDS, RDATA, RData"
          },
          {
            "sbg:category": "Configs",
            "sbg:toolDefaultValue": "gaussian",
            "id": "family",
            "type": {
              "type": "enum",
              "symbols": [
                "gaussian",
                "poisson",
                "binomial"
              ],
              "name": "family"
            },
            "label": "Family",
            "doc": "Depending on the output type (quantitative or qualitative) one of possible values should be chosen: Gaussian, Binomial, Poisson."
          },
          {
            "sbg:category": "Configs",
            "id": "conditional_variant_file",
            "type": "File?",
            "label": "Conditional Variant File",
            "doc": "RData file with data frame of of conditional variants. Columns should include chromosome and variant.id. The alternate allele dosage of these variants will be included as covariates in the analysis.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "id": "covars",
            "type": "string[]?",
            "label": "Covariates",
            "doc": "Names of columns phenotype_file containing covariates."
          },
          {
            "sbg:category": "Configs",
            "id": "group_var",
            "type": "string?",
            "label": "Group variate",
            "doc": "Name of covariate to provide groupings for heterogeneous residual error variances in the mixed model."
          },
          {
            "sbg:toolDefaultValue": "TRUE",
            "sbg:category": "Configs",
            "id": "inverse_normal",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "TRUE",
                  "FALSE"
                ],
                "name": "inverse_normal"
              }
            ],
            "label": "Inverse normal",
            "doc": "TRUE if an inverse-normal transform should be applied to the outcome variable. If Group variate is provided, the transform is done on each group separately."
          },
          {
            "sbg:toolDefaultValue": "3",
            "sbg:category": "Configs",
            "id": "n_pcs",
            "type": "int?",
            "label": "Number of PCs to include as covariates",
            "doc": "Number of PCs to include as covariates."
          },
          {
            "sbg:toolDefaultValue": "marginal",
            "sbg:category": "Configs",
            "id": "rescale_variance",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "marginal",
                  "varcomp",
                  "none"
                ],
                "name": "rescale_variance"
              }
            ],
            "label": "Rescale variance",
            "doc": "Applies only if Inverse normal is TRUE and Group variate is provided. Controls whether to rescale the variance for each group after inverse-normal transform, restoring it to the original variance before the transform. Options are marginal, varcomp, or none."
          },
          {
            "sbg:toolDefaultValue": "TRUE",
            "sbg:category": "Configs",
            "id": "resid_covars",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "TRUE",
                  "FALSE"
                ],
                "name": "resid_covars"
              }
            ],
            "label": "Residual covariates",
            "doc": "Applies only if Inverse normal is TRUE. Logical for whether covariates should be included in the second null model using the residuals as the outcome variable."
          },
          {
            "sbg:category": "Configs",
            "id": "sample_include_file",
            "type": "File?",
            "label": "Sample include file",
            "doc": "RData file with vector of sample.id to include.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "sbg:toolDefaultValue": "1",
            "sbg:category": "Input Options",
            "id": "cpu",
            "type": "int?",
            "label": "CPU",
            "doc": "Number of CPUs for each tool job. Default value: 1."
          },
          {
            "sbg:category": "Configs",
            "sbg:toolDefaultValue": "null_model",
            "id": "output_prefix",
            "type": "string?",
            "label": "Output prefix",
            "doc": "Base for all output file names. By default it is null_model."
          },
          {
            "sbg:category": "General",
            "sbg:toolDefaultValue": "FALSE",
            "id": "norm_bygroup",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "TRUE",
                  "FALSE"
                ],
                "name": "norm_bygroup"
              }
            ],
            "label": "Norm by group",
            "doc": "If TRUE and group_var is provided, the inverse normal transform is done on each group separately."
          }
        ],
        "outputs": [
          {
            "id": "configs",
            "doc": "Config files.",
            "label": "Config files",
            "type": "File[]?",
            "outputBinding": {
              "glob": "*.config*"
            }
          },
          {
            "id": "null_model_phenotypes",
            "doc": "Phenotypes file",
            "label": "Null model Phenotypes file",
            "type": "File?",
            "outputBinding": {
              "glob": "${\n    if(inputs.null_model_file)\n    {\n        return inputs.phenotype_file.basename\n    }\n    else\n    {\n        return \"*phenotypes.RData\"\n    }\n}",
              "outputEval": "$(inheritMetadata(self, inputs.phenotype_file))"
            },
            "sbg:fileTypes": "RData"
          },
          {
            "id": "null_model_files",
            "doc": "Null model file.",
            "label": "Null model file",
            "type": "File[]?",
            "outputBinding": {
              "glob": "${\n    if(inputs.null_model_file)\n    {\n        return inputs.null_model_file.basename\n    }\n    else\n    {\n        if(inputs.output_prefix)\n        {\n            return inputs.output_prefix + '_null_model*RData'\n        }\n        return \"*null_model*RData\"\n    }\n}"
            },
            "sbg:fileTypes": "RData"
          },
          {
            "id": "null_model_params",
            "doc": "Parameter file",
            "label": "Parameter file",
            "type": "File?",
            "outputBinding": {
              "glob": "*.params"
            },
            "sbg:fileTypes": "params"
          },
          {
            "id": "null_model_output",
            "type": "File[]?",
            "outputBinding": {
              "glob": "${\n    if(inputs.null_model_file)\n    {\n        return inputs.null_model_file.basename\n    }\n    else\n    {\n        if(inputs.output_prefix)\n        {\n            return inputs.output_prefix + '_null_model*RData'\n        }\n        return \"*null_model*RData\"\n    }\n}",
              "outputEval": "${\n    var result = []\n    var len = self.length\n    var i;\n\n    for(i=0; i<len; i++){\n        if(!self[i].path.split('/')[self[0].path.split('/').length-1].includes('reportonly')){\n            result.push(self[i])\n        }\n    }\n    return result\n}"
            }
          }
        ],
        "label": "null_model.R",
        "arguments": [
          {
            "prefix": "",
            "shellQuote": false,
            "position": 1,
            "valueFrom": "${\n        return \"Rscript /usr/local/analysis_pipeline/R/null_model.R null_model.config\"\n}"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 0,
            "valueFrom": "${\n    if (inputs.cpu)\n        return 'export NSLOTS=' + inputs.cpu + ' &&'\n    else\n        return ''\n}"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 100,
            "valueFrom": "${\n    return ' >> job.out.log'\n}"
          }
        ],
        "requirements": [
          {
            "class": "ShellCommandRequirement"
          },
          {
            "class": "ResourceRequirement",
            "coresMin": "${\n    if(inputs.cpu){\n        return inputs.cpu\n    }\n    else{\n        return 1\n    }\n}"
          },
          {
            "class": "DockerRequirement",
            "dockerPull": "uwgac/topmed-master:2.8.1"
          },
          {
            "class": "InitialWorkDirRequirement",
            "listing": [
              {
                "entryname": "null_model.config",
                "entry": "${  \n\n    var arg = [];\n    if(inputs.output_prefix){\n        var filename = inputs.output_prefix + \"_null_model\";\n        arg.push('out_prefix \\\"' + filename + '\\\"');\n        var phenotype_filename = inputs.output_prefix + \"_phenotypes.RData\";\n        arg.push('out_phenotype_file \\\"' + phenotype_filename + '\\\"');\n    }\n    else{\n        arg.push('out_prefix \"null_model\"');\n        arg.push('out_phenotype_file \"phenotypes.RData\"');\n    }\n    arg.push('outcome ' + inputs.outcome);\n    arg.push('phenotype_file \"' + inputs.phenotype_file.basename + '\"');\n    if(inputs.gds_files){\n        \n       function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n       }    \n        \n       var gds = inputs.gds_files[0].path.split('/').pop();    \n       var right = gds.split('chr')[1];\n       var chr = [];\n       \n       if(isNumeric(parseInt(right.charAt(1)))) chr.push(right.substr(0,2))\n       else chr.push(right.substr(0,1))\n       \n        arg.push('gds_file \"' + inputs.gds_files[0].basename.split(\"chr\")[0] + \"chr \"+gds.split(\"chr\"+chr)[1] +'\"')\n        \n        \n    }\n    if(inputs.pca_file){\n        arg.push('pca_file \"' + inputs.pca_file.basename + '\"')\n    }\n    if(inputs.relatedness_matrix_file){\n        arg.push('relatedness_matrix_file \"' + inputs.relatedness_matrix_file.basename + '\"')\n    }\n    if(inputs.family){\n        arg.push('family ' + inputs.family)\n    }\n    if(inputs.conditional_variant_file){\n        arg.push('conditional_variant_file \"' + inputs.conditional_variant_file.basename + '\"')\n    }\n    if(inputs.covars){\n        var temp = [];\n        for(var i=0; i<inputs.covars.length; i++){\n            temp.push(inputs.covars[i])\n        }\n        arg.push('covars \"' + temp.join(' ') + '\"')\n    }\n    if(inputs.group_var){\n        arg.push('group_var \"' + inputs.group_var + '\"')\n    }\n    if(inputs.inverse_normal){\n        arg.push('inverse_normal ' + inputs.inverse_normal)\n    }\n    if(inputs.n_pcs){\n        if(inputs.n_pcs > 0)\n            arg.push('n_pcs ' + inputs.n_pcs)\n    }\n    if(inputs.rescale_variance){\n        arg.push('rescale_variance \"' + inputs.rescale_variance + '\"')\n    }\n    if(inputs.resid_covars){\n        arg.push('resid_covars ' + inputs.resid_covars)\n    }\n    if(inputs.sample_include_file){\n        arg.push('sample_include_file \"' + inputs.sample_include_file.basename + '\"')\n    }\n    if(inputs.norm_bygroup){\n        arg.push('norm_bygroup ' + inputs.norm_bygroup)\n    }\n    return arg.join('\\n')\n}",
                "writable": false
              },
              {
                "entry": "${\n    return inputs.phenotype_file\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.gds_files\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.pca_file\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.relatedness_matrix_file\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.conditional_variant_file\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.sample_include_file\n}",
                "writable": true
              }
            ]
          },
          {
            "class": "InlineJavascriptRequirement",
            "expressionLib": [
              "\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};"
            ]
          }
        ],
        "hints": [
          {
            "class": "sbg:AWSInstanceType",
            "value": "r4.8xlarge;ebs-gp2;500"
          },
          {
            "class": "sbg:SaveLogs",
            "value": "job.out.log"
          }
        ],
        "sbg:projectName": "GENESIS toolkit - DEMO",
        "sbg:image_url": null,
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1570633733,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-r/0"
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1571830034,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-r/1"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1571831344,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-r/2"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1572272533,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-r/3"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1573061752,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-r/6"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1573062816,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-r/7"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1574250829,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-r/8"
          },
          {
            "sbg:revision": 7,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1574268733,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-r/9"
          },
          {
            "sbg:revision": 8,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1575643018,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-r/10"
          },
          {
            "sbg:revision": 9,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1581607916,
            "sbg:revisionNotes": "GDS filename correction"
          },
          {
            "sbg:revision": 10,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1581613630,
            "sbg:revisionNotes": "GDS filename correction"
          },
          {
            "sbg:revision": 11,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593598547,
            "sbg:revisionNotes": "Docker image update: 2.8.0 and null_model input excluded"
          },
          {
            "sbg:revision": 12,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593610311,
            "sbg:revisionNotes": "Binomial parameter changed"
          },
          {
            "sbg:revision": 13,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593610371,
            "sbg:revisionNotes": "Binary required"
          },
          {
            "sbg:revision": 14,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593610600,
            "sbg:revisionNotes": "binomial to family"
          },
          {
            "sbg:revision": 15,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593611103,
            "sbg:revisionNotes": "Family"
          },
          {
            "sbg:revision": 16,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593621760,
            "sbg:revisionNotes": "Input descriptions updated."
          },
          {
            "sbg:revision": 17,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602060847,
            "sbg:revisionNotes": "Docker 2.8.1 and SaveLogs hint"
          },
          {
            "sbg:revision": 18,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602065070,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 19,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602076654,
            "sbg:revisionNotes": "Input and output descriptions"
          },
          {
            "sbg:revision": 20,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602144144,
            "sbg:revisionNotes": "Parameter file"
          },
          {
            "sbg:revision": 21,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602147326,
            "sbg:revisionNotes": "report only excluded"
          },
          {
            "sbg:revision": 22,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602149776,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 23,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602153513,
            "sbg:revisionNotes": "Report only excluded"
          },
          {
            "sbg:revision": 24,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602154432,
            "sbg:revisionNotes": "Output eval excluded"
          },
          {
            "sbg:revision": 25,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602505365,
            "sbg:revisionNotes": ""
          },
          {
            "sbg:revision": 26,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1603281262,
            "sbg:revisionNotes": "Family corrected"
          },
          {
            "sbg:revision": 27,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604500553,
            "sbg:revisionNotes": "cwltool"
          },
          {
            "sbg:revision": 28,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604503616,
            "sbg:revisionNotes": "arguments to arg"
          },
          {
            "sbg:revision": 29,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604913685,
            "sbg:revisionNotes": "Stagig"
          },
          {
            "sbg:revision": 30,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604914595,
            "sbg:revisionNotes": "Cwltool"
          },
          {
            "sbg:revision": 31,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604915895,
            "sbg:revisionNotes": "Cwltool"
          },
          {
            "sbg:revision": 32,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604916794,
            "sbg:revisionNotes": "cwltool"
          },
          {
            "sbg:revision": 33,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604918840,
            "sbg:revisionNotes": "cwltool"
          },
          {
            "sbg:revision": 34,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604923710,
            "sbg:revisionNotes": "Staged inputs"
          },
          {
            "sbg:revision": 35,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604925380,
            "sbg:revisionNotes": "Staging"
          },
          {
            "sbg:revision": 36,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604927481,
            "sbg:revisionNotes": "Cwltool"
          },
          {
            "sbg:revision": 37,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604962707,
            "sbg:revisionNotes": "Cwltool"
          },
          {
            "sbg:revision": 38,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1605004147,
            "sbg:revisionNotes": ".path to .basename"
          }
        ],
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-toolkit-demo/null-model-r/38",
        "sbg:revision": 38,
        "sbg:revisionNotes": ".path to .basename",
        "sbg:modifiedOn": 1605004147,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1570633733,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-toolkit-demo",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "boris_majic",
          "dajana_panovic"
        ],
        "sbg:latestRevision": 38,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "a01fd2da60f594b4a7cdd85a7ae3ae932ed876379bba266bdcdc31d174a4350d0"
      },
      "label": "Fit Null Model",
      "sbg:x": 5.5,
      "sbg:y": 19.75
    },
    {
      "id": "null_model_report",
      "in": [
        {
          "id": "family",
          "source": "family"
        },
        {
          "id": "inverse_normal",
          "source": "inverse_normal"
        },
        {
          "id": "null_model_params",
          "source": "null_model_r/null_model_params"
        },
        {
          "id": "phenotype_file",
          "source": "phenotype_file"
        },
        {
          "id": "sample_include_file",
          "source": "sample_include_file"
        },
        {
          "id": "pca_file",
          "source": "pca_file"
        },
        {
          "id": "relatedness_matrix_file",
          "source": "relatedness_matrix_file"
        },
        {
          "id": "null_model_files",
          "source": [
            "null_model_r/null_model_files"
          ]
        },
        {
          "id": "output_prefix",
          "source": "output_prefix"
        },
        {
          "id": "conditional_variant_file",
          "source": "conditional_variant_file"
        },
        {
          "id": "gds_files",
          "source": [
            "gds_files"
          ]
        },
        {
          "id": "n_categories_boxplot",
          "source": "n_categories_boxplot"
        }
      ],
      "out": [
        {
          "id": "html_reports"
        },
        {
          "id": "rmd_files"
        },
        {
          "id": "null_model_report_config"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-toolkit-demo/null-model-report/29",
        "baseCommand": [],
        "inputs": [
          {
            "sbg:category": "General",
            "id": "family",
            "type": {
              "type": "enum",
              "symbols": [
                "gaussian",
                "binomial",
                "poisson"
              ],
              "name": "family"
            },
            "label": "Family",
            "doc": "Possible values: Gaussian, Binomial, Poisson"
          },
          {
            "sbg:category": "General",
            "sbg:toolDefaultValue": "TRUE",
            "id": "inverse_normal",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "TRUE",
                  "FALSE"
                ],
                "name": "inverse_normal"
              }
            ],
            "label": "Inverse normal",
            "doc": "TRUE if an inverse-normal transform should be applied to the outcome variable. If Group variate is provided, the transform is done on each group separately. Default value is TRUE."
          },
          {
            "sbg:category": "Inputs",
            "id": "null_model_params",
            "type": "File",
            "label": "Null Model Params",
            "doc": ".params file generated by null model.",
            "sbg:fileTypes": "params"
          },
          {
            "sbg:category": "Null model",
            "id": "phenotype_file",
            "type": "File?",
            "label": "Phenotype file",
            "doc": "RData file with AnnotatedDataFrame of phenotypes.",
            "sbg:fileTypes": "RData"
          },
          {
            "sbg:category": "Null model",
            "id": "sample_include_file",
            "type": "File?",
            "label": "Sample include file",
            "doc": "RData file with vector of sample.id to include.",
            "sbg:fileTypes": "RData"
          },
          {
            "sbg:category": "Null model",
            "id": "pca_file",
            "type": "File?",
            "label": "PCA File",
            "doc": "RData file with PCA results created by PC-AiR.",
            "sbg:fileTypes": "RData"
          },
          {
            "sbg:category": "Null model",
            "id": "relatedness_matrix_file",
            "type": "File?",
            "label": "Relatedness Matrix File",
            "doc": "RData or GDS file with a kinship matrix or GRM.",
            "sbg:fileTypes": "GDS, RData, gds, RDATA"
          },
          {
            "id": "null_model_files",
            "type": "File[]?",
            "label": "Null model files",
            "doc": "Null model files."
          },
          {
            "id": "output_prefix",
            "type": "string?",
            "label": "Output prefix",
            "doc": "Output prefix."
          },
          {
            "sbg:category": "General",
            "id": "conditional_variant_file",
            "type": "File?",
            "label": "Conditional variant file",
            "doc": "Conditional variant file",
            "sbg:fileTypes": "RData, RDATA"
          },
          {
            "sbg:category": "General",
            "id": "gds_files",
            "type": "File[]?",
            "label": "GDS Files",
            "doc": "GDS files",
            "sbg:fileTypes": "GDS"
          },
          {
            "sbg:toolDefaultValue": "10",
            "id": "n_categories_boxplot",
            "type": "int?",
            "label": "Number of categories in boxplot",
            "doc": "Number of categories in boxplot",
            "default": 10
          }
        ],
        "outputs": [
          {
            "id": "html_reports",
            "doc": "HTML Reports generated by the tool.",
            "label": "HTML Reports",
            "type": "File[]?",
            "outputBinding": {
              "glob": "*.html"
            },
            "sbg:fileTypes": "html"
          },
          {
            "id": "rmd_files",
            "doc": "R markdown files used to generate the HTML reports.",
            "label": "Rmd files",
            "type": "File[]?",
            "outputBinding": {
              "glob": "*.Rmd"
            },
            "sbg:fileTypes": "Rmd"
          },
          {
            "id": "null_model_report_config",
            "doc": "Null model report config",
            "label": "Null model report config",
            "type": "File?",
            "outputBinding": {
              "glob": "*config"
            }
          }
        ],
        "label": "null_model_report",
        "arguments": [
          {
            "prefix": "",
            "shellQuote": false,
            "position": 2,
            "valueFrom": "${\n    return \" Rscript /usr/local/analysis_pipeline/R/null_model_report.R null_model_report.config\"\n}"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 100,
            "valueFrom": "${\n    return ' >> job.out.log'\n}"
          }
        ],
        "requirements": [
          {
            "class": "ShellCommandRequirement"
          },
          {
            "class": "DockerRequirement",
            "dockerPull": "uwgac/topmed-master:2.8.1"
          },
          {
            "class": "InitialWorkDirRequirement",
            "listing": [
              {
                "entryname": "null_model_report.config",
                "entry": "${\n    var config = \"\";\n    if(inputs.family)\n    {\n        config += \"family \" + inputs.family + \"\\n\";\n    }\n    \n    if(inputs.inverse_normal)\n    {\n        config += \"inverse_normal \" + inputs.inverse_normal + \"\\n\";\n    }\n\n    if(inputs.output_prefix)\n    {\n        config += \"out_prefix \\\"\" + inputs.output_prefix + \"\\\"\\n\";\n    }\n    else\n    {\n        config += \"out_prefix \\\"null_model\\\"\" + \"\\n\";\n    }\n    \n    if(inputs.n_categories_boxplot){\n        \n        config += \"n_categories_boxplot \" + inputs.n_categories_boxplot + \"\\n\";\n    }\n    return config\n}",
                "writable": false
              },
              {
                "entry": "${\n    return inputs.null_model_params\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.phenotype_file\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.sample_include_file\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.pca_file\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.relatedness_matrix_file\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.null_model_files\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.conditional_variant_file\n}",
                "writable": true
              },
              {
                "entry": "${\n    return inputs.gds_files\n}",
                "writable": true
              }
            ]
          },
          {
            "class": "InlineJavascriptRequirement"
          }
        ],
        "hints": [
          {
            "class": "sbg:SaveLogs",
            "value": "job.out.log"
          }
        ],
        "sbg:projectName": "GENESIS toolkit - DEMO",
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1570638120,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/0"
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1570725894,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/1"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1573061757,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/2"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1574271142,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/4"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1591110143,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/5"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593598494,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/6"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593611042,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/9"
          },
          {
            "sbg:revision": 7,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593621230,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/10"
          },
          {
            "sbg:revision": 8,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602060536,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/11"
          },
          {
            "sbg:revision": 9,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602065168,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/12"
          },
          {
            "sbg:revision": 10,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602076754,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/null-model-report/13"
          },
          {
            "sbg:revision": 11,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602149870,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 12,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1603717510,
            "sbg:revisionNotes": "Config cleaning"
          },
          {
            "sbg:revision": 13,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604504695,
            "sbg:revisionNotes": "cwltool"
          },
          {
            "sbg:revision": 14,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604504897,
            "sbg:revisionNotes": "cwltool"
          },
          {
            "sbg:revision": 15,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604505777,
            "sbg:revisionNotes": "cwltool"
          },
          {
            "sbg:revision": 16,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604914652,
            "sbg:revisionNotes": "Cwltool"
          },
          {
            "sbg:revision": 17,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604923918,
            "sbg:revisionNotes": "Staged"
          },
          {
            "sbg:revision": 18,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604925559,
            "sbg:revisionNotes": "Staging"
          },
          {
            "sbg:revision": 19,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604927522,
            "sbg:revisionNotes": "Cwltool"
          },
          {
            "sbg:revision": 20,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604960501,
            "sbg:revisionNotes": "Scr.R"
          },
          {
            "sbg:revision": 21,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604961179,
            "sbg:revisionNotes": "Scr.R"
          },
          {
            "sbg:revision": 22,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604961573,
            "sbg:revisionNotes": "Scr.R"
          },
          {
            "sbg:revision": 23,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604962104,
            "sbg:revisionNotes": "Scr.R"
          },
          {
            "sbg:revision": 24,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604962543,
            "sbg:revisionNotes": "Scr.R"
          },
          {
            "sbg:revision": 25,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604962858,
            "sbg:revisionNotes": "Notwrittable"
          },
          {
            "sbg:revision": 26,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604964290,
            "sbg:revisionNotes": "scr.R"
          },
          {
            "sbg:revision": 27,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1604964499,
            "sbg:revisionNotes": "Scr.R"
          },
          {
            "sbg:revision": 28,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1605004215,
            "sbg:revisionNotes": "Staged"
          },
          {
            "sbg:revision": 29,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608120879,
            "sbg:revisionNotes": "Null model report config output added"
          }
        ],
        "sbg:image_url": null,
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-toolkit-demo/null-model-report/29",
        "sbg:revision": 29,
        "sbg:revisionNotes": "Null model report config output added",
        "sbg:modifiedOn": 1608120879,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1570638120,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-toolkit-demo",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic",
          "boris_majic"
        ],
        "sbg:latestRevision": 29,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "a0b38889480af037d80fdb4fe89877df92e17601468849e9a8bc0b034cdb3c54a"
      },
      "label": "Null Model Report",
      "sbg:x": 474.8600769042969,
      "sbg:y": -248.57232666015625
    }
  ],
  "requirements": [
    {
      "class": "InlineJavascriptRequirement"
    },
    {
      "class": "StepInputExpressionRequirement"
    }
  ],
  "sbg:projectName": "GENESIS pipelines - DEMO",
  "sbg:revisionsInfo": [
    {
      "sbg:revision": 0,
      "sbg:modifiedBy": "boris_majic",
      "sbg:modifiedOn": 1571921340,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/null-model/6"
    },
    {
      "sbg:revision": 1,
      "sbg:modifiedBy": "boris_majic",
      "sbg:modifiedOn": 1574269224,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/null-model/14"
    },
    {
      "sbg:revision": 2,
      "sbg:modifiedBy": "boris_majic",
      "sbg:modifiedOn": 1575642956,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/null-model/15"
    },
    {
      "sbg:revision": 3,
      "sbg:modifiedBy": "boris_majic",
      "sbg:modifiedOn": 1576765551,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/null-model/16"
    },
    {
      "sbg:revision": 4,
      "sbg:modifiedBy": "boris_majic",
      "sbg:modifiedOn": 1580990768,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/null-model/20"
    },
    {
      "sbg:revision": 5,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1583937759,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/null-model/22"
    },
    {
      "sbg:revision": 6,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1584372098,
      "sbg:revisionNotes": "Final Wrap"
    },
    {
      "sbg:revision": 7,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1591621996,
      "sbg:revisionNotes": "Null model report updated"
    },
    {
      "sbg:revision": 8,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1593599483,
      "sbg:revisionNotes": "New docker image: 2.8.0 and null_model input excluded"
    },
    {
      "sbg:revision": 9,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1593613764,
      "sbg:revisionNotes": "Description updated"
    },
    {
      "sbg:revision": 10,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1593693054,
      "sbg:revisionNotes": "Input descriptions updated on nod level"
    },
    {
      "sbg:revision": 11,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1596459813,
      "sbg:revisionNotes": "Benchmarking updated"
    },
    {
      "sbg:revision": 12,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1600431373,
      "sbg:revisionNotes": "Benchmarking updated"
    },
    {
      "sbg:revision": 13,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1600673447,
      "sbg:revisionNotes": "Benchmarking table updated"
    },
    {
      "sbg:revision": 14,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602062011,
      "sbg:revisionNotes": "Docker 2.8.1 and SaveLogs hint"
    },
    {
      "sbg:revision": 15,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602069532,
      "sbg:revisionNotes": "SaveLogs update"
    },
    {
      "sbg:revision": 16,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602143534,
      "sbg:revisionNotes": "Input description update"
    },
    {
      "sbg:revision": 17,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602156414,
      "sbg:revisionNotes": "Version 2.8.1"
    },
    {
      "sbg:revision": 18,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602246467,
      "sbg:revisionNotes": "Input and output description updated"
    },
    {
      "sbg:revision": 19,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602573484,
      "sbg:revisionNotes": "Report only excluded from the output"
    },
    {
      "sbg:revision": 20,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1603284498,
      "sbg:revisionNotes": "Family corrected"
    },
    {
      "sbg:revision": 21,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1603796948,
      "sbg:revisionNotes": "Config cleaning"
    },
    {
      "sbg:revision": 22,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1603903133,
      "sbg:revisionNotes": "Config cleaning"
    },
    {
      "sbg:revision": 23,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1603962791,
      "sbg:revisionNotes": "Config cleaning"
    },
    {
      "sbg:revision": 24,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1606726822,
      "sbg:revisionNotes": "CWLtool compatible"
    },
    {
      "sbg:revision": 25,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1608903269,
      "sbg:revisionNotes": "CWLtool compatible"
    }
  ],
  "sbg:image_url": "https://platform.sb.biodatacatalyst.nhlbi.nih.gov/ns/brood/images/boris_majic/genesis-pipelines-demo/null-model/25.png",
  "sbg:license": "MIT",
  "sbg:categories": [
    "GWAS",
    "Genomics",
    "CWL1.0"
  ],
  "sbg:toolAuthor": "TOPMed DCC",
  "sbg:appVersion": [
    "v1.1"
  ],
  "id": "https://api.sb.biodatacatalyst.nhlbi.nih.gov/v2/apps/boris_majic/genesis-pipelines-demo/null-model/25/raw/",
  "sbg:id": "boris_majic/genesis-pipelines-demo/null-model/25",
  "sbg:revision": 25,
  "sbg:revisionNotes": "CWLtool compatible",
  "sbg:modifiedOn": 1608903269,
  "sbg:modifiedBy": "dajana_panovic",
  "sbg:createdOn": 1571921340,
  "sbg:createdBy": "boris_majic",
  "sbg:project": "boris_majic/genesis-pipelines-demo",
  "sbg:sbgMaintained": false,
  "sbg:validationErrors": [],
  "sbg:contributors": [
    "dajana_panovic",
    "boris_majic"
  ],
  "sbg:latestRevision": 25,
  "sbg:publisher": "sbg",
  "sbg:content_hash": "ac551f1d6aa93ab8e45aecd78b1941a0772a987704799f2eaff7fad1e4be9e7cb"
}