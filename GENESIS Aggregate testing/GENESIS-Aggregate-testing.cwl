{
  "class": "Workflow",
  "cwlVersion": "v1.1",
  "doc": "**Aggregate Association Testing workflow** runs aggregate association tests, using Burden, SKAT [1], fastSKAT [2], SMMAT [3], or SKAT-O [4] to aggregate a user-defined set of variants. Association tests are parallelized by segments within chromosomes.\n\nDefine segments splits the genome into segments and assigns each aggregate unit to a segment based on the position of its first variant. Note that number of segments refers to the whole genome, not a number of segments per chromosome. Association testing is then for each segment in parallel, before combining results on chromosome level. Finally, the last step creates QQ and Manhattan plots.\n\nAggregate tests are typically used to jointly test rare variants. The **Alt freq max** parameter allows specification of the maximum alternate allele frequency allowable for inclusion in the test. Included variants are usually weighted using either a function of allele frequency (specified via the **Weight Beta** parameter) or some other annotation information (specified via the **Variant weight file** and **Weight user** parameters). \n\nWhen running a burden test, the effect estimate is for each additional unit of burden; there are no effect size estimates for the other tests. Multiple alternate alleles for a single variant are treated separately.\n\nThis workflow utilizes the *assocTestAggregate* function from the GENESIS software.\n\n\n### Common Use Cases\n * This workflow is designed to perform multi-variant association testing on a user-defined groups of variants.\n\n\n### Common Issues and important notes:\n* This pipeline expects that **GDS Files**, **Variant Include Files**, and **Variant group files** are separated per chromosome, and that files are properly named. It is expected that chromosome is included in the filename in following format: chr## , where ## is the name of the chromosome (1-24 or X, Y). Chromosome can be included at any part of the filename.  Examples: data_subset_chr1.vcf,  data_chr1_subset.vcf, chr1_data_subset.vcf.\n\n* If **Weight Beta** parameter is set, it needs to follow proper convention, two space-delimited floating point numbers.\n\n* **Number of segments** parameter, if provided, needs to be equal or higher than number of chromosomes.\n\n* Testing showed that default parameters for **CPU** and **memory GB** (8GB) are sufficient for testing studies (up to 50k samples), however different null models might increase the requirements.\n\n### Performance Benchmarking\n\nIn the following table you can find estimates of running time and cost. \n\n| Samples &nbsp; &nbsp;|  | Rel. matrix in NM &nbsp; &nbsp; | Test &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;   | Parallel instances &nbsp; &nbsp;| Instance type &nbsp; &nbsp;| Instance  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp;  | CPU &nbsp; &nbsp; | RAM (GB) &nbsp; &nbsp;| Time    &nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp;  | Cost |\n| ------- | -------- | -------------------- | ------ | --------------------- | ---------------- | ------------- | --- | -------- | ----------- | ---- |\n| 10K     |        | w/o                  | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 11 min | 16$  |\n| 10K     |         | Sparse               | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 10min  | 17$  |\n| 10K     |         | Dense                | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 12 min | 16$  |\n| 36K     |         | w/o                  | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 46 min | 28$  |\n| 36K     |         | Sparse               | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 9        | 1 h, 50 min | 31$  |\n| 36K     |         | Dense                | Burden | 8                     | On Dm            | r5.12xlarge   | 4   | 36       | 2h, 59 min  | 66$  |\n| 50K     |         | w/o                  | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 2 h, 28 min | 40$  |\n| 50K     |         | Sparse               | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 9        | 2 h, 11 min | 43$  |\n| 50K     |         | Dense                | Burden | 8                     | On Dm            | r5.24xlarge   | 8   | 70       | 4 h, 47 min | 208$ |\n| 50K     |         | Dense                | Burden | 8                     | On Dm            | r5.24xlarge   | 8   | 70       | 4 h, 30 min | 218$ |\n| 50K     |         | Dense                | Burden | 8                     | On Dm            | r5.24xlarge   | 8   | 70       | 9 h         | 218$ |\n| 10K     |         | w/o                  | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 1 h, 55 min | 16$  |\n| 10K     |         | Sparse               | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 2 h         | 17$  |\n| 10K     |         | Dense                | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 2 h, 40 min | 16$  |\n| 36K     |         | w/o                  | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 2 h, 17 min | 30$  |\n| 36K     |         | Sparse               | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 9        | 2 h, 30 min | 30$  |\n| 36K     |         | Dense                | Burden | 8                     | On Dm            | n1-highmem-32 | 4   | 36       | 6 h         | 91$  |\n| 50K     |         | w/o                  | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 5 h, 50 min | 43$  |\n| 50K     |         | Sparse               | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 9        | 5 h, 50 min | 40$  |\n| 50K     |         | Dense                | Burden | 8                     | On Dm            | n1-highmem-96 | 8   | 70       | 6 h         | 270$ |     \n| 10K |  | w/o    | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min | 16$  |\n| 10K |  | Sparse | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min | 17$  |\n| 10K |  | Dense  | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 17 min | 17$  |\n| 36K |  | w/o    | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 47 min | 27$  |\n| 36K |  | Sparse | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 1 h, 50 min | 31$  |\n| 36K |  | Dense  | SKAT | 8 | On Dm | r5.12xlarge   | 6  | 48  | 5 h, 5 min  | 110$ |\n| 50K |  | w/o    | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 2 h, 27 min | 40$  |\n| 50K |  | Sparse | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 2 h, 23 min | 44$  |\n| 50K |  | Dense  | SKAT | 8 | On Dm | r5.24xlarge   | 13 | 100 | 11 h, 2 min | 500$ |\n| 50K |  | Dense  | SKAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 9 h         | 435$ |\n| 50K |  | Dense  | SKAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 18 h        | 435$ |\n| 10K |  | w/o    | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h, 50 min | 17$  |\n| 10K |  | Sparse | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h         | 16$  |\n| 10K |  | Dense  | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 50 min | 17$  |\n| 36K |  | w/o    | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 45 min | 30$  |\n| 36K |  | Sparse | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 2 h, 20 min | 30$  |\n| 36K |  | Dense  | SKAT | 8 | On Dm | n1-highmem-32 | 6  | 48  | 12 h        | 162$ |\n| 50K |  | w/o    | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 5 h         | 45$  |\n| 50K |  | Sparse | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 5 h         | 45$  |\n| 50K |  | Dense  | SKAT | 8 | On Dm | n1-highmem-96 | 13 | 100 | 14 h        | 620$ |\n| 50K |  | Dense  | SKAT | 8 | On Dm | n1-highmem-96 | 12 | 90  | 14 h        | 620$ |\n| 10K |  | w/o    | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min  | 16$  |\n| 10K |  | Sparse | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 16 min  | 16$  |\n| 10K |  | Dense  | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 18 min  | 17$  |\n| 36K |  | w/o    | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 45 min  | 28$  |\n| 36K |  | Sparse | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 1 h, 48 min  | 32$  |\n| 36K |  | Dense  | SMMAT | 8 | On Dm | r5.12xlarge   | 6  | 48  | 5h           | 111$ |\n| 50K |  | w/o    | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 2 h, 30 min  | 40$  |\n| 50K |  | Sparse | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 2 h, 47 min  | 44$  |\n| 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 13 | 100 | 11 h, 30 min | 500$ |\n| 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 9 h          | 435$ |\n| 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 18 h         | 435$ |\n| 10K |  | w/o    | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h 30 min   | 15$  |\n| 10K |  | Sparse | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h          | 16$  |\n| 10K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 50 min  | 17$  |\n| 36K |  | w/o    | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 43 min  | 30$  |\n| 36K |  | Sparse | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 2 h, 25 min  | 30$  |\n| 36K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-32 | 6  | 48  | 12 h         | 160$ |\n| 50K |  | w/o    | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 5 h          | 42$  |\n| 50K |  | Sparse | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 5 h          | 50$  |\n| 50K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-96 | 13 | 100 | 14 h         | 620$ |\n| 50K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-96 | 12 | 90  | 14 h         | 620$ |\n| 10K |  | w/o    | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 14 min  | 16$  |\n| 10K |  | Sparse | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min  | 16$  |\n| 10K |  | Dense  | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 17 min  | 17$  |\n| 36K |  | w/o    | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 50 min  | 28$  |\n| 36K |  | Sparse | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 1 h, 40 min  | 34$  |\n| 36K |  | Dense  | Fast SKAT | 8 | On Dm | r5.12xlarge   | 6  | 50  | 5 h, 30 min  | 135$ |\n| 50K |  | w/o    | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 10  | 1 h, 30 min  | 40$  |\n| 50K |  | Sparse | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 10  | 1 h, 30 min  | 43$  |\n| 50K |  | Dense  | Fast SKAT | 8 | On Dm | r5.24xlarge   | 13 | 100 | 11 h, 41 min | 501$ |\n| 10K |  | w/o    | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h, 30 min  | 16$  |\n| 10K |  | Sparse | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h, 30 min  | 16$  |\n| 10K |  | Dense  | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 50 min  | 17$  |\n| 36K |  | w/o    | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 3 h          | 30$  |\n| 36K |  | Sparse | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 4 h, 30min   | 32$  |\n| 36K |  | Dense  | Fast SKAT | 8 | On Dm | n1-highmem-32 | 6  | 50  | 11 h         | 160$ |\n| 50K |  | w/o    | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 10  | 3 h          | 45$  |\n| 50K |  | Sparse | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 10  | 3 h          | 45$  |\n| 50K |  | Dense  | Fast SKAT | 8 | On Dm | n1-highmem-96 | 13 | 100 | 14 h         | 650$ |\n\nIn tests performed we used **1000G** (tasks with 2.5k participants) and **TOPMed freeze5** datasets (tasks with 10k or more participants). All these tests are done with applied **MAF < 1% filter.** There are **70 mio** variants with MAF <= 1% in **1000G** and **460 mio** in **TOPMed freeze5 dataset**. Typically, aggregate tests only use a subset of these variants; e.g. grouped by gene. Computational performance will vary depending on how many total variants are tested, and how many variants are included in each aggregation unit.\n\n*For more details on **spot/preemptible instances** please visit the [Knowledge Center](https://docs.sevenbridges.com/docs/about-spot-instances).*     \n\n### API Python Implementation\n\nThe app's draft task can also be submitted via the **API**. In order to learn how to get your **Authentication token** and **API endpoint** for the corresponding Platform visit our [documentation](https://github.com/sbg/sevenbridges-python#authentication-and-configuration).\n\n```python\nfrom sevenbridges import Api\n\nauthentication_token, api_endpoint = \"enter_your_token\", \"enter_api_endpoint\"\napi = Api(token=authentication_token, url=api_endpoint)\n# Get project_id/app_id from your address bar. Example: https://f4c.sbgenomics.com/u/your_username/project/app\nproject_id, app_id = \"your_username/project\", \"your_username/project/app\"\n# Get file names from files in your project. Example: Names are taken from Data/Public Reference Files.\ninputs = {\n    \"input_gds_files\": api.files.query(project=project_id, names=[\"basename_chr1.gds\", \"basename_chr2.gds\", ..]),\n    \"variant_group_files\": api.files.query(project=project_id, names=[\"variant_group_chr1.RData\", \"variant_group_chr2.RData\", ..]),\n    \"phenotype_file\": api.files.query(project=project_id, names=[\"name_of_phenotype_file\"])[0],\n    \"null_model_file\": api.files.query(project=project_id, names=[\"name_of_null_model_file\"])[0]\n}\ntask = api.tasks.create(name='Aggregate Association Testing - API Run', project=project_id, app=app_id, inputs=inputs, run=False)\n```\nInstructions for installing and configuring the API Python client, are provided on [github](https://github.com/sbg/sevenbridges-python#installation). For more information about using the API Python client, consult [sevenbridges-python documentation](http://sevenbridges-python.readthedocs.io/en/latest/). **More examples** are available [here](https://github.com/sbg/okAPI).\n\nAdditionally, [API R](https://github.com/sbg/sevenbridges-r) and [API Java](https://github.com/sbg/sevenbridges-java) clients are available. To learn more about using these API clients please refer to the [API R client documentation](https://sbg.github.io/sevenbridges-r/), and [API Java client documentation](https://docs.sevenbridges.com/docs/java-library-quickstart).\n\n\n### References\n[1] [SKAT](https://dx.doi.org/10.1016%2Fj.ajhg.2011.05.029)  \n[2] [fastSKAT](https://doi.org/10.1002/gepi.22136)  \n[3] [SMMAT](https://doi.org/10.1016/j.ajhg.2018.12.012)  \n[4] [SKAT-O](https://doi.org/10.1093/biostatistics/kxs014)  \n[5] [GENESIS](https://f4c.sbgenomics.com/u/boris_majic/genesis-pipelines-dev/apps/doi.org/10.1093/bioinformatics/btz567)",
  "label": "Aggregate Association Testing",
  "$namespaces": {
    "sbg": "https://sevenbridges.com"
  },
  "inputs": [
    {
      "id": "segment_length",
      "type": "int?",
      "label": "Segment length",
      "doc": "Segment length in kb, used for parallelization.",
      "sbg:toolDefaultValue": "10000kb",
      "sbg:x": -493.4073791503906,
      "sbg:y": 145.2222900390625
    },
    {
      "id": "n_segments",
      "type": "int?",
      "label": "Number of segments",
      "doc": "Number of segments, used for parallelization (overrides Segment length). Note that this parameter defines the number of segments for the entire genome, so using this argument with selected chromosomes may result in fewer segments than you expect (and the minimum is one segment per chromosome).",
      "sbg:x": -499.4447326660156,
      "sbg:y": 263.33343505859375
    },
    {
      "id": "genome_build",
      "type": [
        "null",
        {
          "type": "enum",
          "symbols": [
            "hg19",
            "hg38"
          ],
          "name": "genome_build"
        }
      ],
      "label": "Genome build",
      "doc": "Genome build for the genotypes in the GDS file (hg19 or hg38). Used to divide the genome into segments for parallel processing.",
      "sbg:toolDefaultValue": "hg38",
      "sbg:x": -490.4073791503906,
      "sbg:y": 387.18524169921875
    },
    {
      "id": "aggregate_type",
      "type": [
        "null",
        {
          "type": "enum",
          "symbols": [
            "position",
            "allele"
          ],
          "name": "aggregate_type"
        }
      ],
      "label": "Aggregate type",
      "doc": "Type of aggregate grouping. Options are to select variants by allele (unique variants) or position (regions of interest).",
      "sbg:toolDefaultValue": "allele",
      "sbg:x": -69.71428680419922,
      "sbg:y": 438.71429443359375
    },
    {
      "id": "variant_group_files",
      "sbg:fileTypes": "RDATA",
      "type": "File[]",
      "label": "Variant group files",
      "doc": "RData file with data.frame defining aggregate groups. If aggregate_type is allele, columns should be group_id, chr, pos, ref, alt. If aggregate_type is position, columns should be group_id, chr, start, end. Files may be separated by chromosome with \u2018chr##\u2019 string corresponding to each GDS file. If Variant Include file is specified, groups will be subset to included variants.",
      "sbg:x": -82.28571319580078,
      "sbg:y": 124.14286041259766
    },
    {
      "id": "variant_include_files",
      "sbg:fileTypes": "RDATA",
      "type": "File[]?",
      "label": "Variant Include Files",
      "doc": "RData file(s) with a vector of variant.id to include. Files may be separated by chromosome with \u2018chr##\u2019 string corresponding to each GDS file. If not provided, all variants in the GDS file will be included in the analysis.",
      "sbg:x": 41.50267791748047,
      "sbg:y": -170.37432861328125
    },
    {
      "id": "variant_weight_file",
      "sbg:fileTypes": "RDATA",
      "type": "File?",
      "label": "Variant Weight file",
      "doc": "RData file(s) with data.frame specifying variant weights. Columns should contain either variant.id or all of (chr, pos, ref, alt). Files may be separated by chromosome with \u2018chr##\u2019 string corresponding to each GDS file. If not provided, all variants will be given equal weight in the test.",
      "sbg:x": 475,
      "sbg:y": -107.42857360839844
    },
    {
      "id": "weight_user",
      "type": "string?",
      "label": "Weight user",
      "doc": "Name of column in variant_weight_file or variant_group_file containing the weight for each variant. Overrides Weight beta.",
      "sbg:x": 477.8571472167969,
      "sbg:y": 16.571426391601562
    },
    {
      "id": "weight_beta",
      "type": "string?",
      "label": "Weight Beta",
      "doc": "Parameters of the Beta distribution used to determine variant weights based on minor allele frequency; two space delimited values. \"1 1\" is flat (uniform) weights, \"0.5 0.5\" is proportional to the Madsen-Browning weights, and \"1 25\" gives the Wu weights. This parameter is ignored if weight_user is provided.",
      "sbg:toolDefaultValue": "1 1",
      "sbg:x": 368.8571472167969,
      "sbg:y": -41.85714340209961
    },
    {
      "id": "test",
      "type": [
        "null",
        {
          "type": "enum",
          "symbols": [
            "burden",
            "skat",
            "smmat",
            "fastskat",
            "skato"
          ],
          "name": "test"
        }
      ],
      "label": "Test",
      "doc": "Test to perform. Options are burden, SKAT, SMMAT, fast-SKAT, or SKAT-O.",
      "sbg:toolDefaultValue": "Burden",
      "sbg:x": 113.71428680419922,
      "sbg:y": 540
    },
    {
      "id": "rho",
      "type": "float[]?",
      "label": "Rho",
      "doc": "A numeric value or list of values in range [0,1] specifying the rho parameter when test is SKAT-O. 0 is a standard SKAT test, 1 is a burden test, and intermediate values are a weighted combination of both.",
      "sbg:toolDefaultValue": "0",
      "sbg:x": 202,
      "sbg:y": 601.5714721679688
    },
    {
      "id": "phenotype_file",
      "sbg:fileTypes": "RDATA",
      "type": "File",
      "label": "Phenotype file",
      "doc": "RData file with an AnnotatedDataFrame of phenotypes and covariates. Sample identifiers must be in column named \u201csample.id\u201d. It is recommended to use the phenotype file output by the GENESIS Null Model app.",
      "sbg:x": 116,
      "sbg:y": 666.7142944335938
    },
    {
      "id": "pass_only",
      "type": "boolean?",
      "label": "Pass only",
      "doc": "TRUE to select only variants with FILTER=PASS. If FALSE, variants that failed the quality filter will be included in the test.",
      "sbg:toolDefaultValue": "TRUE",
      "sbg:x": 200.42857360839844,
      "sbg:y": 732.5714111328125
    },
    {
      "id": "null_model_file",
      "sbg:fileTypes": "RDATA",
      "type": "File",
      "label": "Null model file",
      "doc": "RData file containing a null model object. Run the GENESIS Null Model app to create this file.",
      "sbg:x": 115.85713958740234,
      "sbg:y": 797.1428833007812
    },
    {
      "id": "memory_gb",
      "type": "float?",
      "label": "Memory GB",
      "doc": "Memory in GB per job.",
      "sbg:toolDefaultValue": "8",
      "sbg:x": 202.14285278320312,
      "sbg:y": 859.4285888671875
    },
    {
      "id": "cpu",
      "type": "int?",
      "label": "CPU",
      "doc": "Number of CPUs for each job.",
      "sbg:toolDefaultValue": "1",
      "sbg:x": 114.57142639160156,
      "sbg:y": 917
    },
    {
      "id": "alt_freq_max",
      "type": "float?",
      "label": "Alt Freq Max",
      "doc": "Maximum alternate allele frequency of variants to include in the test. Default: 1 (no filtering of variants by frequency). ",
      "sbg:toolDefaultValue": "1",
      "sbg:x": 203.7142791748047,
      "sbg:y": 982.5714111328125
    },
    {
      "id": "disable_thin",
      "type": "boolean?",
      "label": "Disable Thin",
      "doc": "Logical for whether to thin points in the QQ and Manhattan plots. By default, points are thinned in dense regions to reduce plotting time. If this parameter is set to TRUE, all variant p-values will be included in the plots, and the plotting will be very long and memory intensive.",
      "sbg:x": 1502.486572265625,
      "sbg:y": 762.502685546875
    },
    {
      "id": "group_id",
      "type": "string?",
      "label": "Group ID",
      "doc": "Alternate name for group_id column in Variant Group file.",
      "sbg:x": -85.23925018310547,
      "sbg:y": 321.7161865234375
    },
    {
      "id": "thin_nbins",
      "type": "int?",
      "label": "Thin N bins",
      "doc": "Number of bins to use for thinning.",
      "sbg:toolDefaultValue": "10",
      "sbg:x": 1457.91943359375,
      "sbg:y": 650.1939697265625
    },
    {
      "id": "thin_npoints",
      "type": "int?",
      "label": "Thin N points",
      "doc": "Number of points in each bin after thinning.",
      "sbg:toolDefaultValue": "10000",
      "sbg:x": 1318.279541015625,
      "sbg:y": 616.2745971679688
    },
    {
      "id": "out_prefix",
      "type": "string",
      "label": "Output prefix",
      "doc": "Prefix that will be included in all output files.",
      "sbg:x": 83.72884368896484,
      "sbg:y": 1033.336669921875
    },
    {
      "id": "input_gds_files",
      "sbg:fileTypes": "GDS",
      "type": "File[]",
      "label": "GDS files",
      "doc": "GDS files with genotype data for variants to be tested for association. If multiple files are selected, they will be run in parallel. Files separated by chromosome are expected to have \u2018chr##\u2019 strings indicating chromosome number, where \u2018##\u2019 can be (1-24, X, Y). Output files for each chromosome will include the corresponding chromosome number.",
      "sbg:x": -206.37063598632812,
      "sbg:y": -21.074094772338867
    },
    {
      "id": "truncate_pval_threshold",
      "type": "float?",
      "label": "Truncate pval threshold",
      "doc": "Maximum p-value to display in truncated QQ and manhattan plots.",
      "sbg:x": 1219.759033203125,
      "sbg:y": 798.991455078125
    },
    {
      "id": "plot_mac_threshold",
      "type": "int?",
      "label": "Plot MAC threshold",
      "doc": "Minimum minor allele count for variants or aggregate units to include in plots (if different from MAC threshold).",
      "sbg:x": 1397.79150390625,
      "sbg:y": 874.508056640625
    }
  ],
  "outputs": [
    {
      "id": "assoc_combined",
      "outputSource": [
        "assoc_combine_r/assoc_combined"
      ],
      "sbg:fileTypes": "RDATA",
      "type": "File[]?",
      "label": "Association test results",
      "doc": "RData file with data.frame of association test results (test statistic, p-value, etc.) See the documentation of the GENESIS R package for detailed description of output.",
      "sbg:x": 1726.478271484375,
      "sbg:y": 337.85418701171875
    },
    {
      "id": "assoc_plots_1",
      "outputSource": [
        "assoc_plots/assoc_plots"
      ],
      "sbg:fileTypes": "PNG",
      "type": "File[]?",
      "label": "Association test plots",
      "doc": "QQ and Manhattan Plots of p-values in association test results.",
      "sbg:x": 1866.478271484375,
      "sbg:y": 505.85418701171875
    }
  ],
  "steps": [
    {
      "id": "define_segments_r",
      "in": [
        {
          "id": "segment_length",
          "source": "segment_length"
        },
        {
          "id": "n_segments",
          "source": "n_segments"
        },
        {
          "id": "genome_build",
          "source": "genome_build"
        }
      ],
      "out": [
        {
          "id": "config"
        },
        {
          "id": "define_segments_output"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-toolkit-demo/define-segments-r/7",
        "baseCommand": [],
        "inputs": [
          {
            "sbg:altPrefix": "-s",
            "sbg:toolDefaultValue": "10000",
            "sbg:category": "Optional parameters",
            "id": "segment_length",
            "type": "int?",
            "inputBinding": {
              "prefix": "--segment_length",
              "shellQuote": false,
              "position": 1
            },
            "label": "Segment length",
            "doc": "Segment length in kb, used for paralelization."
          },
          {
            "sbg:altPrefix": "-n",
            "sbg:category": "Optional parameters",
            "id": "n_segments",
            "type": "int?",
            "inputBinding": {
              "prefix": "--n_segments",
              "shellQuote": false,
              "position": 2
            },
            "label": "Number of segments",
            "doc": "Number of segments, used for paralelization (overrides Segment length). Note that this parameter defines the number of segments for the entire genome, so using this argument with selected chromosomes may result in fewer segments than you expect (and the minimum is one segment per chromosome)."
          },
          {
            "sbg:toolDefaultValue": "hg38",
            "sbg:category": "Configs",
            "id": "genome_build",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "hg19",
                  "hg38"
                ],
                "name": "genome_build"
              }
            ],
            "label": "Genome build",
            "doc": "Genome build for the genotypes in the GDS file (hg19 or hg38). Used to divide the genome into segments for parallel processing.",
            "default": "hg38"
          }
        ],
        "outputs": [
          {
            "id": "config",
            "doc": "Config file.",
            "label": "Config file",
            "type": "File?",
            "outputBinding": {
              "glob": "*.config"
            },
            "sbg:fileTypes": "CONFIG"
          },
          {
            "id": "define_segments_output",
            "doc": "Segments txt file.",
            "label": "Segments file",
            "type": "File?",
            "outputBinding": {
              "glob": "segments.txt"
            },
            "sbg:fileTypes": "TXT"
          }
        ],
        "label": "define_segments.R",
        "arguments": [
          {
            "prefix": "",
            "separate": false,
            "shellQuote": false,
            "position": 100,
            "valueFrom": "define_segments.config"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 0,
            "valueFrom": "Rscript /usr/local/analysis_pipeline/R/define_segments.R"
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
                "entryname": "define_segments.config",
                "entry": "${\n    var argument = [];\n    argument.push('out_file \"segments.txt\"')\n    if(inputs.genome_build){\n         argument.push('genome_build \"' + inputs.genome_build + '\"')\n    }\n    return argument.join('\\n')\n}",
                "writable": false
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
        "sbg:image_url": null,
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1570638123,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/define-segments-r/0"
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1573739972,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/define-segments-r/1"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593600096,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/define-segments-r/2"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593621237,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/define-segments-r/3"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602060533,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/define-segments-r/4"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602065172,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/define-segments-r/5"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1603798126,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/define-segments-r/6"
          },
          {
            "sbg:revision": 7,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1606727052,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/define-segments-r/7"
          }
        ],
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-toolkit-demo/define-segments-r/7",
        "sbg:revision": 7,
        "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/define-segments-r/7",
        "sbg:modifiedOn": 1606727052,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1570638123,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-toolkit-demo",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic",
          "boris_majic"
        ],
        "sbg:latestRevision": 7,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "ac91280a285017188ee26cefc0b78bff35fee3b892f03d9368945d0c17a7fae39",
        "sbg:copyOf": "boris_majic/genesis-toolkit-dev/define-segments-r/7"
      },
      "label": "Define Segments",
      "sbg:x": -224.14285278320312,
      "sbg:y": 260.5714416503906
    },
    {
      "id": "sbg_prepare_segments",
      "in": [
        {
          "id": "input_gds_files",
          "source": [
            "sbg_gds_renamer/renamed_variants"
          ]
        },
        {
          "id": "segments_file",
          "source": "define_segments_r/define_segments_output"
        },
        {
          "id": "aggregate_files",
          "source": [
            "aggregate_list/aggregate_list"
          ]
        },
        {
          "id": "variant_include_files",
          "source": [
            "variant_include_files"
          ]
        }
      ],
      "out": [
        {
          "id": "gds_output"
        },
        {
          "id": "segments"
        },
        {
          "id": "aggregate_output"
        },
        {
          "id": "variant_include_output"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-pipelines-dev/sbg-prepare-segments/14",
        "baseCommand": [],
        "inputs": [
          {
            "sbg:category": "Inputs",
            "id": "input_gds_files",
            "type": "File[]",
            "label": "GDS files",
            "doc": "GDS files.",
            "sbg:fileTypes": "GDS"
          },
          {
            "sbg:category": "Inputs",
            "id": "segments_file",
            "type": "File",
            "label": "Segments file",
            "doc": "Segments file.",
            "sbg:fileTypes": "TXT"
          },
          {
            "sbg:category": "Inputs",
            "id": "aggregate_files",
            "type": "File[]?",
            "label": "Aggregate files",
            "doc": "Aggregate files.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "sbg:category": "Inputs",
            "id": "variant_include_files",
            "type": "File[]?",
            "label": "Variant Include Files",
            "doc": "RData file containing ids of variants to be included.",
            "sbg:fileTypes": "RData"
          }
        ],
        "outputs": [
          {
            "id": "gds_output",
            "doc": "GDS files.",
            "label": "GDS files",
            "type": "File[]?",
            "outputBinding": {
              "loadContents": true,
              "glob": "*.txt",
              "outputEval": "${\n     function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    \n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"chr\")[1];\n        \n        if(isNumeric(chrom_num.charAt(1)))\n        {\n            chr_array.push(chrom_num.substr(0,2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(0,1))\n        }\n        return chr_array.toString()\n    }\n    \n    \n    \n    function pair_chromosome_gds(file_array){\n        var gdss = {};\n        for(var i=0; i<file_array.length; i++){\n            gdss[find_chromosome(file_array[i].path)] = file_array[i]\n        }\n        return gdss\n    }\n\n    var input_gdss = pair_chromosome_gds(inputs.input_gds_files)\n    var output_gdss = [];\n    var segments = self[0].contents.split('\\n');\n    var chr;\n    \n    segments = segments.slice(1)\n    for(var i=0;i<segments.length;i++){\n        chr = segments[i].split('\\t')[0]\n        if(chr in input_gdss){\n            output_gdss.push(input_gdss[chr])\n        }\n    }\n    return output_gdss\n}"
            },
            "sbg:fileTypes": "GDS"
          },
          {
            "id": "segments",
            "doc": "Segments.",
            "label": "Segments",
            "type": "int[]?",
            "outputBinding": {
              "loadContents": true,
              "glob": "*.txt",
              "outputEval": "${\n     function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    \n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"chr\")[1];\n        \n        if(isNumeric(chrom_num.charAt(1)))\n        {\n            chr_array.push(chrom_num.substr(0,2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(0,1))\n        }\n        return chr_array.toString()\n    }\n    \n    function pair_chromosome_gds(file_array){\n        var gdss = {};\n        for(var i=0; i<file_array.length; i++){\n            gdss[find_chromosome(file_array[i].path)] = file_array[i]\n        }\n        return gdss\n    }\n    \n    var input_gdss = pair_chromosome_gds(inputs.input_gds_files)\n    var output_segments = []\n    var segments = self[0].contents.split('\\n');\n    segments = segments.slice(1)\n    var chr;\n    \n    for(var i=0;i<segments.length;i++){\n        chr = segments[i].split('\\t')[0]\n        if(chr in input_gdss){\n            output_segments.push(i+1)\n        }\n    }\n    return output_segments\n    \n}"
            }
          },
          {
            "id": "aggregate_output",
            "doc": "Aggregate output.",
            "label": "Aggregate output",
            "type": [
              "null",
              {
                "type": "array",
                "items": [
                  "null",
                  "File"
                ]
              }
            ],
            "outputBinding": {
              "loadContents": true,
              "glob": "*.txt",
              "outputEval": "${\n     function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    \n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"chr\")[1];\n        \n        if(isNumeric(chrom_num.charAt(1)))\n        {\n            chr_array.push(chrom_num.substr(0,2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(0,1))\n        }\n        return chr_array.toString()\n    }\n    \n    function pair_chromosome_gds(file_array){\n        var gdss = {};\n        for(var i=0; i<file_array.length; i++){\n            gdss[find_chromosome(file_array[i].path)] = file_array[i]\n        }\n        return gdss\n    }\n    function pair_chromosome_gds_special(file_array, agg_file){\n        var gdss = {};\n        for(var i=0; i<file_array.length; i++){\n            gdss[find_chromosome(file_array[i].path)] = agg_file\n        }\n        return gdss\n    }\n    var input_gdss = pair_chromosome_gds(inputs.input_gds_files)\n    var segments = self[0].contents.split('\\n');\n    segments = segments.slice(1)\n    var chr;\n    \n    if(inputs.aggregate_files){\n        if (inputs.aggregate_files[0] != null){\n            if (inputs.aggregate_files[0].basename.includes('chr'))\n                var input_aggregate_files = pair_chromosome_gds(inputs.aggregate_files);\n            else\n                var input_aggregate_files = pair_chromosome_gds_special(inputs.input_gds_files, inputs.aggregate_files[0].path);\n            var output_aggregate_files = []\n            for(var i=0;i<segments.length;i++){\n                chr = segments[i].split('\\t')[0]\n                if(chr in input_aggregate_files){\n                    output_aggregate_files.push(input_aggregate_files[chr])\n                }\n                else if(chr in input_gdss){\n                    output_aggregate_files.push(null)\n                }\n            }\n            return output_aggregate_files\n        }\n    }\n    else{\n        var null_outputs = []\n        for(var i=0; i<segments.length; i++){\n            chr = segments[i].split('\\t')[0]\n            if(chr in input_gdss){\n                null_outputs.push(null)\n            }\n        }\n        return null_outputs\n    }\n}"
            }
          },
          {
            "id": "variant_include_output",
            "doc": "Variant Include Output",
            "label": "Variant Include Output",
            "type": [
              "null",
              {
                "type": "array",
                "items": [
                  "null",
                  "File"
                ]
              }
            ],
            "outputBinding": {
              "loadContents": true,
              "glob": "*.txt",
              "outputEval": "${\n     function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    \n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"chr\")[1];\n        \n        if(isNumeric(chrom_num.charAt(1)))\n        {\n            chr_array.push(chrom_num.substr(0,2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(0,1))\n        }\n        return chr_array.toString()\n    }\n    \n    function pair_chromosome_gds(file_array){\n        var gdss = {};\n        for(var i=0; i<file_array.length; i++){\n            gdss[find_chromosome(file_array[i].path)] = file_array[i]\n        }\n        return gdss\n    }\n    var input_gdss = pair_chromosome_gds(inputs.input_gds_files)\n    var segments = self[0].contents.split('\\n');\n    segments = segments.slice(1)\n    var chr;\n    \n    if(inputs.variant_include_files){\n        if (inputs.variant_include_files[0] != null){\n            var input_variant_files = pair_chromosome_gds(inputs.variant_include_files)\n            var output_variant_files = []\n            for(var i=0;i<segments.length;i++){\n                chr = segments[i].split('\\t')[0]\n                if(chr in input_variant_files){\n                    output_variant_files.push(input_variant_files[chr])\n                }\n                else if(chr in input_gdss){\n                    output_variant_files.push(null)\n                }\n            }\n            return output_variant_files\n        }\n    }\n    else{\n        var null_outputs = [];\n        for(var i=0; i<segments.length; i++){\n            chr = segments[i].split('\\t')[0]\n            if(chr in input_gdss){\n                null_outputs.push(null)\n            }\n        }\n        return null_outputs\n    }\n}"
            }
          }
        ],
        "label": "SBG Prepare Segments",
        "arguments": [
          {
            "prefix": "",
            "shellQuote": false,
            "position": 0,
            "valueFrom": "${\n    return \"cp \" + inputs.segments_file.path + \" .\"\n}"
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
            "class": "InlineJavascriptRequirement"
          }
        ],
        "hints": [
          {
            "class": "sbg:SaveLogs",
            "value": "job.out.log"
          }
        ],
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1571048402,
            "sbg:revisionNotes": null
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1571048422,
            "sbg:revisionNotes": "Import"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1574267860,
            "sbg:revisionNotes": "Create special case when single multichromosomal aggregate file is provided"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583155192,
            "sbg:revisionNotes": "Var added in variable initialisation step"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583158233,
            "sbg:revisionNotes": "find_chromosome changed to support *_chrXX_merged.gds"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602061171,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608289003,
            "sbg:revisionNotes": "Pajce 1"
          },
          {
            "sbg:revision": 7,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608296924,
            "sbg:revisionNotes": "pajce 2"
          },
          {
            "sbg:revision": 8,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608562054,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 9,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608562705,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 10,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608567888,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 11,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608568045,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 12,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608729624,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 13,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608729837,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 14,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608905868,
            "sbg:revisionNotes": "New docker"
          }
        ],
        "sbg:projectName": "GENESIS pipelines - DEV",
        "sbg:image_url": null,
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-pipelines-dev/sbg-prepare-segments/14",
        "sbg:revision": 14,
        "sbg:revisionNotes": "New docker",
        "sbg:modifiedOn": 1608905868,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1571048402,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-pipelines-dev",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic",
          "boris_majic"
        ],
        "sbg:latestRevision": 14,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "af5431cfdc789d53445974b82b534a1ba1c6df2ac79d7b39af88dce65def8cb34"
      },
      "label": "SBG Prepare Segments",
      "sbg:x": 264.8571472167969,
      "sbg:y": 102.57142639160156
    },
    {
      "id": "aggregate_list",
      "in": [
        {
          "id": "variant_group_file",
          "source": "variant_group_files"
        },
        {
          "id": "aggregate_type",
          "source": "aggregate_type"
        },
        {
          "id": "group_id",
          "source": "group_id"
        }
      ],
      "out": [
        {
          "id": "aggregate_list"
        },
        {
          "id": "config_file"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-toolkit-demo/aggregate-list/11",
        "baseCommand": [],
        "inputs": [
          {
            "sbg:category": "Input File",
            "id": "variant_group_file",
            "type": "File",
            "label": "Variant group file",
            "doc": "RData file with data frame defining aggregate groups. If aggregate_type is allele, columns should be group_id, chromosome, position, ref, alt. If aggregate_type is position, columns should be group_id, chromosome, start, end.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "sbg:toolDefaultValue": "allele",
            "sbg:category": "Input Options",
            "id": "aggregate_type",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "position",
                  "allele"
                ],
                "name": "aggregate_type"
              }
            ],
            "label": "Aggregate type",
            "doc": "Type of aggregate grouping. Options are to select variants by allele (unique variants) or position (regions of interest). Default is allele."
          },
          {
            "sbg:toolDefaultValue": "aggregate_list.RData",
            "id": "out_file",
            "type": "string?",
            "label": "Out file",
            "doc": "Out file."
          },
          {
            "sbg:category": "General",
            "sbg:toolDefaultValue": "group_id",
            "id": "group_id",
            "type": "string?",
            "label": "Group ID",
            "doc": "Alternate name for group_id column."
          }
        ],
        "outputs": [
          {
            "id": "aggregate_list",
            "label": "Aggregate list",
            "type": "File?",
            "outputBinding": {
              "glob": "${\n    var comm;\n    \n    if (!inputs.variant_group_file.basename.includes('chr'))\n    {\n        return '*RData'\n    }\n  if (!inputs.out_file) {\n    comm = \"aggregate_list*.RData\"\n  } else {\n    \tcomm = inputs.out_file + \".RData\"\n  }\n  return comm\n}"
            },
            "sbg:fileTypes": "RDATA"
          },
          {
            "id": "config_file",
            "label": "Config file",
            "type": "File?",
            "outputBinding": {
              "glob": "*.config"
            },
            "sbg:fileTypes": "CONFIG"
          }
        ],
        "label": "aggregate_list",
        "arguments": [
          {
            "prefix": "",
            "shellQuote": false,
            "position": 0,
            "valueFrom": "${  \n    var cmd_line;\n    if (inputs.variant_group_file)\n    {\n        cmd_line = \"cp \" + inputs.variant_group_file.path + \" \" + inputs.variant_group_file.basename\n    \n        return cmd_line\n    }\n    else\n    {\n        return \"echo variant group file not provided\"\n    }\n}"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 0,
            "valueFrom": "${\n    var cmd_line = \"\";\n    if (inputs.variant_group_file)\n    {\n        cmd_line = \"&& Rscript /usr/local/analysis_pipeline/R/aggregate_list.R aggregate_list.config \"\n    }\n\n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"chr\")[1];\n        \n        if(isNumeric(chrom_num.charAt(1)))\n        {\n            chr_array.push(chrom_num.substr(0,2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(0,1))\n        }\n        return chr_array.toString()\n    }\n    \n    function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    \n    var chromosome;\n    \n    if (inputs.variant_group_file.basename.includes('chr'))\n    {\n\t    chromosome = find_chromosome(inputs.variant_group_file.path)\n        cmd_line += \"--chromosome \" + chromosome \n        return cmd_line\n    }\n    return ''\n    \n    \n}"
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
                "entryname": "aggregate_list.config",
                "entry": "${\n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"/\").pop();\n        chrom_num = file.split(\"chr\")[1]\n        \n        if(isNumeric(chrom_num.charAt(1)))\n        {\n            chr_array.push(chrom_num.substr(0,2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(0,1))\n        }\n        return chr_array.toString();\n    }\n    \n    function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    \n    var argument = [];\n    \n    \n    if (inputs.variant_group_file.basename.includes('chr'))\n    {   \n        var chr = find_chromosome(inputs.variant_group_file.path);\n        var chromosomes_basename = inputs.variant_group_file.path.slice(0,-6).replace(/\\/.+\\//g,\"\");\n         \n        var i; \n        for(i = chromosomes_basename.length - 1; i > 0; i--)\n            if(chromosomes_basename[i] != 'X' && chromosomes_basename[i] != \"Y\" && isNaN(chromosomes_basename[i]))\n                break;\n        chromosomes_basename = inputs.variant_group_file.basename.split('chr'+chr)[0]+\"chr \"+ inputs.variant_group_file.basename.split('chr'+chr)[1]\n        \n        argument.push('variant_group_file \"' + chromosomes_basename + '\"')\n    }\n    else\n    {\n        argument.push('variant_group_file \"' + inputs.variant_group_file.basename + '\"')\n    }\n    \n    if(inputs.out_file)\n        if (inputs.variant_group_file.basename.includes('chr')){\n            \n            argument.push('out_file \"' + inputs.out_file + ' .RData\"')}\n        else\n            argument.push('out_file \"' + inputs.out_file + '.RData\"')\n    else\n    {\n        if (inputs.variant_group_file.basename.includes('chr'))\n            argument.push('out_file \"aggregate_list_chr .RData\"')\n        else\n            argument.push('out_file aggregate_list.RData')\n    }\n        \n\n    if(inputs.aggregate_type)\n        argument.push('aggregate_type \"' + inputs.aggregate_type + '\"')\n    \n    if(inputs.group_id)\n        argument.push('group_id \"' + inputs.group_id + '\"')\n    \n    return argument.join('\\n') + '\\n'\n\n}",
                "writable": false
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
        "sbg:image_url": null,
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1570638144,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/aggregate-list/0"
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1573666778,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/aggregate-list/1"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1574267882,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/aggregate-list/4"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583426575,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/aggregate-list/5"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583952445,
            "sbg:revisionNotes": "find_chromosome updated"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1584006432,
            "sbg:revisionNotes": "Comand line --chromosome updated"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1591618975,
            "sbg:revisionNotes": "Variant group filename updated"
          },
          {
            "sbg:revision": 7,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593600153,
            "sbg:revisionNotes": "New docker image: 2.8.0"
          },
          {
            "sbg:revision": 8,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593621946,
            "sbg:revisionNotes": "Inputs description updated."
          },
          {
            "sbg:revision": 9,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602060804,
            "sbg:revisionNotes": "Docker 2.8.1 and SaveLogs hint"
          },
          {
            "sbg:revision": 10,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602065115,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 11,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608826312,
            "sbg:revisionNotes": "CWLtool prep"
          }
        ],
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-toolkit-demo/aggregate-list/11",
        "sbg:revision": 11,
        "sbg:revisionNotes": "CWLtool prep",
        "sbg:modifiedOn": 1608826312,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1570638144,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-toolkit-demo",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic",
          "boris_majic"
        ],
        "sbg:latestRevision": 11,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "ac07aeeb403224371db07ea50ae81405284bab5f3dd9677605c10f1a3d41f88b3"
      },
      "label": "Aggregate List",
      "scatter": [
        "variant_group_file"
      ],
      "sbg:x": 106.8010025024414,
      "sbg:y": 349.28460693359375
    },
    {
      "id": "assoc_aggregate",
      "in": [
        {
          "id": "gds_file",
          "linkMerge": "merge_flattened",
          "source": [
            "sbg_prepare_segments/gds_output"
          ],
          "valueFrom": "$(self ? [].concat(self)[0] : self)"
        },
        {
          "id": "null_model_file",
          "source": "null_model_file"
        },
        {
          "id": "phenotype_file",
          "source": "phenotype_file"
        },
        {
          "id": "aggregate_variant_file",
          "linkMerge": "merge_flattened",
          "source": [
            "sbg_prepare_segments/aggregate_output"
          ],
          "valueFrom": "$(self ? [].concat(self)[0] : self)"
        },
        {
          "id": "out_prefix",
          "source": "out_prefix"
        },
        {
          "id": "rho",
          "source": [
            "rho"
          ]
        },
        {
          "id": "segment_file",
          "linkMerge": "merge_flattened",
          "source": [
            "define_segments_r/define_segments_output"
          ],
          "valueFrom": "$(self ? [].concat(self)[0] : self)"
        },
        {
          "id": "test",
          "source": "test"
        },
        {
          "id": "variant_include_file",
          "linkMerge": "merge_flattened",
          "source": [
            "sbg_prepare_segments/variant_include_output"
          ],
          "valueFrom": "$(self ? [].concat(self)[0] : self)"
        },
        {
          "id": "weight_beta",
          "source": "weight_beta"
        },
        {
          "id": "segment",
          "linkMerge": "merge_flattened",
          "source": [
            "sbg_prepare_segments/segments"
          ],
          "valueFrom": "$(self ? [].concat(self)[0] : self)"
        },
        {
          "id": "aggregate_type",
          "source": "aggregate_type"
        },
        {
          "id": "alt_freq_max",
          "source": "alt_freq_max"
        },
        {
          "id": "pass_only",
          "source": "pass_only"
        },
        {
          "id": "variant_weight_file",
          "source": "variant_weight_file"
        },
        {
          "id": "weight_user",
          "source": "weight_user"
        },
        {
          "id": "cpu",
          "source": "cpu"
        },
        {
          "id": "memory_gb",
          "source": "memory_gb"
        },
        {
          "id": "genome_build",
          "source": "genome_build"
        }
      ],
      "out": [
        {
          "id": "assoc_aggregate"
        },
        {
          "id": "config"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-toolkit-demo/assoc_aggregate/13",
        "baseCommand": [],
        "inputs": [
          {
            "sbg:category": "Input File",
            "id": "gds_file",
            "type": "File",
            "label": "GDS file",
            "doc": "GDS File.",
            "sbg:fileTypes": "GDS"
          },
          {
            "sbg:category": "Input File",
            "id": "null_model_file",
            "type": "File",
            "label": "Null model file",
            "doc": "Null model file.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "sbg:category": "Input File",
            "id": "phenotype_file",
            "type": "File",
            "label": "Phenotype file",
            "doc": "RData file with AnnotatedDataFrame of phenotypes. Used for plotting kinship estimates separately by study.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "id": "aggregate_variant_file",
            "type": "File",
            "label": "Aggregate variant file",
            "doc": "File with regions that we want to test.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "sbg:toolDefaultValue": "assoc_aggregate",
            "sbg:category": "Inputs",
            "id": "out_prefix",
            "type": "string?",
            "label": "Output prefix",
            "doc": "Output prefix."
          },
          {
            "sbg:toolDefaultValue": "0",
            "id": "rho",
            "type": "float[]?",
            "label": "Rho",
            "doc": "A numeric value or list of values in range [0,1] specifying the rho parameter when test is skat. 0 is a standard SKAT test, 1 is a score burden test, and multiple values is a SKAT-O test."
          },
          {
            "sbg:category": "Input files",
            "id": "segment_file",
            "type": "File?",
            "label": "Segment File",
            "doc": "Segment File.",
            "sbg:fileTypes": "TXT"
          },
          {
            "sbg:toolDefaultValue": "burden",
            "id": "test",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "burden",
                  "skat",
                  "smmat",
                  "fastskat",
                  "skato"
                ],
                "name": "test"
              }
            ],
            "label": "Test type",
            "doc": "Test to perform. Options are burden, skat, smmat, fastskat, or skato."
          },
          {
            "id": "variant_include_file",
            "type": "File?",
            "label": "Variant Include File",
            "doc": "Variants to be included when perform testing.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "sbg:toolDefaultValue": "1 1",
            "id": "weight_beta",
            "type": "string?",
            "label": "Weight Beta",
            "doc": "Parameters of the Beta distribution used to determine variant weights, two space delimited values. \"1 1\" is flat weights, \"0.5 0.5\" is proportional to the Madsen-Browning weights, and \"1 25\" gives the Wu weights. This parameter is ignored if weight_user is provided."
          },
          {
            "sbg:category": "Input Options",
            "id": "segment",
            "type": "int?",
            "inputBinding": {
              "prefix": "--segment",
              "shellQuote": false,
              "position": 10
            },
            "label": "Segment number",
            "doc": "Segment Number"
          },
          {
            "sbg:toolDefaultValue": "Allele",
            "id": "aggregate_type",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "allele",
                  "position"
                ],
                "name": "aggregate_type"
              }
            ],
            "label": "Aggregate type",
            "doc": "Type of aggregate grouping. Options are to select variants by allele (unique variants) or position (regions of interest)."
          },
          {
            "sbg:toolDefaultValue": "1",
            "id": "alt_freq_max",
            "type": "float?",
            "label": "Alt Freq Max",
            "doc": "Maximum alternate allele frequency to consider."
          },
          {
            "sbg:toolDefaultValue": "TRUE",
            "id": "pass_only",
            "type": "boolean?",
            "label": "Pass only",
            "doc": "TRUE to select only variants with FILTER=PASS."
          },
          {
            "id": "variant_weight_file",
            "type": "File?",
            "label": "Variant Weight file",
            "doc": "Variant Weight file."
          },
          {
            "id": "weight_user",
            "type": "string?",
            "label": "Weight user",
            "doc": "Name of column in variant_weight_file or variant_group_file containing the weight for each variant."
          },
          {
            "sbg:category": "Input options",
            "sbg:toolDefaultValue": "1",
            "id": "cpu",
            "type": "int?",
            "label": "CPU",
            "doc": "Number of CPUs for each tool job. Default value: 1."
          },
          {
            "sbg:category": "Input options",
            "sbg:toolDefaultValue": "8",
            "id": "memory_gb",
            "type": "float?",
            "label": "memory GB",
            "doc": "Memory in GB per job. Default value: 8."
          },
          {
            "id": "genome_build",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "hg19",
                  "hg38"
                ],
                "name": "genome_build"
              }
            ],
            "label": "Genome build",
            "doc": "Genome build for the genotypes in the GDS file (hg19 or hg38). Used to divide the genome into segments for parallel processing."
          }
        ],
        "outputs": [
          {
            "id": "assoc_aggregate",
            "label": "Assoc aggregate output",
            "type": "File?",
            "outputBinding": {
              "glob": "${\n    /*\n  if (!inputs.out_prefix) {\n    comm = \"assoc_aggregate*.RData\"\n  } else {\n    \tcomm = inputs.out_prefix + \".RData\"\n  }\n  return comm */\n  return \"*.RData\"\n}"
            },
            "sbg:fileTypes": "RDATA"
          },
          {
            "id": "config",
            "label": "Config file",
            "type": "File?",
            "outputBinding": {
              "glob": "*.config"
            },
            "sbg:fileTypes": "CONFIG"
          }
        ],
        "label": "assoc_aggregate",
        "arguments": [
          {
            "prefix": "",
            "shellQuote": false,
            "position": 1,
            "valueFrom": "${\n    var cmd_line = \"Rscript /usr/local/analysis_pipeline/R/assoc_aggregate.R assoc_aggregate.config \";\n\n    function isNumeric(s) {\n\n        return !isNaN(s - parseFloat(s));\n    }\n\n    function find_chromosome(file){\n\n        var chr_array = [];\n        var chrom_num = file.split(\"/\").pop();\n        chrom_num = chrom_num.split(\".\")[0]\n        \n        if(isNumeric(chrom_num.charAt(chrom_num.length-2)))\n        {\n            chr_array.push(chrom_num.substr(chrom_num.length - 2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(chrom_num.length - 1))\n        }\n\n        return chr_array.toString()\n    }\n    \n// \tchromosome = find_chromosome(inputs.gds_file.path)\n//     cmd_line += \"--chromosome \" + chromosome \n    return cmd_line\n    \n}"
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
            "ramMin": "${\n    if(inputs.memory_gb)\n        return parseFloat(inputs.memory_gb * 1024)\n    else\n        return 8*1024\n}",
            "coresMin": "${ if(inputs.cpu)\n        return inputs.cpu \n    else \n        return 1\n}"
          },
          {
            "class": "DockerRequirement",
            "dockerPull": "uwgac/topmed-master:2.8.1"
          },
          {
            "class": "InitialWorkDirRequirement",
            "listing": [
              {
                "entryname": "assoc_aggregate.config",
                "entry": "${\n        function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"chr\")[1];\n        \n        if(isNumeric(chrom_num.charAt(1)))\n        {\n            chr_array.push(chrom_num.substr(0,2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(0,1))\n        }\n        return chr_array.toString()\n    }\n        \n    \n    var chr = find_chromosome(inputs.gds_file.path);\n    \n    var config = \"\";\n    \n    if(inputs.out_prefix)\n        config += \"out_prefix \\\"\" + inputs.out_prefix + \"_chr\"+chr + \"\\\"\\n\"\n    else\n    {\n        var data_prefix = inputs.gds_file.basename.split('chr');\n        var data_prefix2 = inputs.gds_file.basename.split('.chr');\n        \n        if (data_prefix.length == data_prefix2.length)\n            config += 'out_prefix \"' + data_prefix2[0] + '_aggregate_chr' + chr + inputs.gds_file.basename.split('chr'+chr)[1].split('.gds')[0] +'\"'+ \"\\n\";\n        else\n            config += 'out_prefix \"' + data_prefix[0] + 'aggregate_chr' + chr +inputs.gds_file.basename.split('chr'+chr)[1].split('.gds')[0]+'\"' + \"\\n\";\n    } \n    if(inputs.gds_file)\n        config += \"gds_file \\\"\" + inputs.gds_file.path + \"\\\"\\n\"\n    if(inputs.phenotype_file)\n        config += \"phenotype_file \\\"\" + inputs.phenotype_file.path + \"\\\"\\n\"\n    if(inputs.aggregate_variant_file)\n        config += \"aggregate_variant_file \\\"\" + inputs.aggregate_variant_file.path + \"\\\"\\n\"\n    if(inputs.null_model_file)\n        config += \"null_model_file \\\"\" + inputs.null_model_file.path + \"\\\"\\n\"\n    if(inputs.null_model_params)\n        config += \"null_model_params \\\"\" + inputs.null_model_params.path + \"\\\"\\n\"\n    if(inputs.rho)\n    {\n        config += \"rho \\\"\";;\n        for(var i=0; i<inputs.rho.length; i++)\n        {\n            config += inputs.rho[i].toString() + \" \";\n        }\n        config += \"\\\"\\n\";\n    }\n    if(inputs.segment_file)\n        config += \"segment_file \\\"\" + inputs.segment_file.path + \"\\\"\\n\"\n    if(inputs.test)\n       config += \"test \\\"\" + inputs.test + \"\\\"\\n\"\n    if(inputs.test_type)\n        config += \"test_type \\\"\" + inputs.test_type + \"\\\"\\n\"\n    if(inputs.variant_include_file)\n        config +=\"variant_include_file \\\"\" + inputs.variant_include_file.path + \"\\\"\\n\"\n    if(inputs.weight_beta)\n        config +=\"weight_beta \\\"\" + inputs.weight_beta + \"\\\"\\n\"\n    if(inputs.aggregate_type)\n        config +=\"aggregate_type \\\"\" + inputs.aggregate_type + \"\\\"\\n\"\n    if(inputs.alt_freq_max)\n        config +=\"alt_freq_max \" + inputs.alt_freq_max + \"\\n\"\n    if(!inputs.pass_only)\n        config += \"pass_only FALSE\"+ \"\\n\"\n    if(inputs.variant_weight_file)\n        config +=\"variant_weight_file \\\"\" + inputs.variant_weight_file + \"\\\"\\n\"\n    if(inputs.weight_user)\n        config +=\"weight_user \\\"\" + inputs.weight_user + \"\\\"\\n\"\n    if(inputs.genome_build)\n        config +=\"genome_build \\\"\" + inputs.genome_build + \"\\\"\\n\"    \n        \n    return config\n}",
                "writable": false
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
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1570638141,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/0"
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1572520967,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/1"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1573666781,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/2"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583774265,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/3"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583775650,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/4"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583847218,
            "sbg:revisionNotes": "Output prefix corrected"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583873542,
            "sbg:revisionNotes": ""
          },
          {
            "sbg:revision": 7,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593600204,
            "sbg:revisionNotes": "New docker image: 2.8.0"
          },
          {
            "sbg:revision": 8,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593621893,
            "sbg:revisionNotes": "Inputs description updated"
          },
          {
            "sbg:revision": 9,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1594657928,
            "sbg:revisionNotes": "parseFloat"
          },
          {
            "sbg:revision": 10,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602060759,
            "sbg:revisionNotes": "Docker 2.8.1 and SaveLogs hint"
          },
          {
            "sbg:revision": 11,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602065154,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 12,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1603726598,
            "sbg:revisionNotes": "Config cleaning"
          },
          {
            "sbg:revision": 13,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608826571,
            "sbg:revisionNotes": "CWLtool prep"
          }
        ],
        "sbg:projectName": "GENESIS toolkit - DEMO",
        "sbg:image_url": null,
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-toolkit-demo/assoc_aggregate/13",
        "sbg:revision": 13,
        "sbg:revisionNotes": "CWLtool prep",
        "sbg:modifiedOn": 1608826571,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1570638141,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-toolkit-demo",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic",
          "boris_majic"
        ],
        "sbg:latestRevision": 13,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "ae557365f1c5d59d6f5852a42b53aa3ac55f0856629fc83129aff7845a5f3fe42"
      },
      "label": "Aggregate Association Test",
      "scatter": [
        "gds_file",
        "aggregate_variant_file",
        "variant_include_file",
        "segment"
      ],
      "scatterMethod": "dotproduct",
      "sbg:x": 767.2857666015625,
      "sbg:y": 436.4285583496094
    },
    {
      "id": "sbg_flattenlists",
      "in": [
        {
          "id": "input_list",
          "source": [
            "assoc_aggregate/assoc_aggregate"
          ],
          "valueFrom": "${     var out = [];     for (var i = 0; i<self.length; i++){         if (self[i])    out.push(self[i])     }     return out }"
        }
      ],
      "out": [
        {
          "id": "output_list"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-pipelines-dev/sbg-flattenlists/6",
        "baseCommand": [
          "echo"
        ],
        "inputs": [
          {
            "sbg:category": "File inputs",
            "id": "input_list",
            "type": "File[]?",
            "label": "Input list of files and lists",
            "doc": "List of inputs, can be any combination of lists of files and single files, it will be combined into a single list of files at the output."
          }
        ],
        "outputs": [
          {
            "id": "output_list",
            "doc": "Single list of files that combines all files from all inputs.",
            "label": "Output list of files",
            "type": "File[]?",
            "outputBinding": {
              "outputEval": "${\n    function flatten(files) {\n        var a = [];\n        for (var i = 0; i < files.length; i++) {\n            if (files[i]) {\n                if (files[i].constructor == Array) a = a.concat(flatten(files[i]))\n                else a = a.concat(files[i])\n            }\n        }\n        return a\n    }\n\n    {\n        if (inputs.input_list) {\n            var arr = [].concat(inputs.input_list);\n            var return_array = [];\n            return_array = flatten(arr)\n            return return_array\n        }\n    }\n}"
            }
          }
        ],
        "doc": "###**Overview** \n\nSBG FlattenLists is used to merge any combination of single file and list of file inputs into a single list of files. This is important because most tools and the CWL specification doesn't allow array of array types, and combinations of single file and array need to be converted into a single list for tools that can process a list of files.\n\n###**Input** \n\nAny combination of input nodes that are of types File or array of File, and any tool outputs that produce types File or array of File.\n\n###**Output** \n\nSingle array of File list containing all Files from all inputs combined, provided there are no duplicate files in those lists.\n\n###**Usage example** \n\nExample of usage is combining the outputs of two tools, one which produces a single file, and the other that produces an array of files, so that the next tool, which takes in an array of files, can process them together.",
        "label": "SBG FlattenLists",
        "arguments": [
          {
            "shellQuote": false,
            "position": 0,
            "valueFrom": "\"Output"
          },
          {
            "shellQuote": false,
            "position": 1,
            "valueFrom": "is"
          },
          {
            "shellQuote": false,
            "position": 2,
            "valueFrom": "now"
          },
          {
            "shellQuote": false,
            "position": 3,
            "valueFrom": "a"
          },
          {
            "shellQuote": false,
            "position": 4,
            "valueFrom": "single"
          },
          {
            "shellQuote": false,
            "position": 5,
            "valueFrom": "list\""
          }
        ],
        "requirements": [
          {
            "class": "ShellCommandRequirement"
          },
          {
            "class": "ResourceRequirement",
            "ramMin": 1000,
            "coresMin": 1
          },
          {
            "class": "DockerRequirement",
            "dockerPull": "uwgac/topmed-master:2.8.1"
          },
          {
            "class": "InitialWorkDirRequirement",
            "listing": [
              "$(inputs.input_list)"
            ]
          },
          {
            "class": "InlineJavascriptRequirement",
            "expressionLib": [
              "var updateMetadata = function(file, key, value) {\n    file['metadata'][key] = value;\n    return file;\n};\n\n\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};\n\nvar toArray = function(file) {\n    return [].concat(file);\n};\n\nvar groupBy = function(files, key) {\n    var groupedFiles = [];\n    var tempDict = {};\n    for (var i = 0; i < files.length; i++) {\n        var value = files[i]['metadata'][key];\n        if (value in tempDict)\n            tempDict[value].push(files[i]);\n        else tempDict[value] = [files[i]];\n    }\n    for (var key in tempDict) {\n        groupedFiles.push(tempDict[key]);\n    }\n    return groupedFiles;\n};\n\nvar orderBy = function(files, key, order) {\n    var compareFunction = function(a, b) {\n        if (a['metadata'][key].constructor === Number) {\n            return a['metadata'][key] - b['metadata'][key];\n        } else {\n            var nameA = a['metadata'][key].toUpperCase();\n            var nameB = b['metadata'][key].toUpperCase();\n            if (nameA < nameB) {\n                return -1;\n            }\n            if (nameA > nameB) {\n                return 1;\n            }\n            return 0;\n        }\n    };\n\n    files = files.sort(compareFunction);\n    if (order == undefined || order == \"asc\")\n        return files;\n    else\n        return files.reverse();\n};"
            ]
          }
        ],
        "hints": [
          {
            "class": "sbg:SaveLogs",
            "value": "job.out.log"
          }
        ],
        "sbg:projectName": "GENESIS pipelines - DEV",
        "sbg:toolAuthor": "Seven Bridges",
        "sbg:cmdPreview": "echo \"Output is now a single list\"",
        "sbg:image_url": null,
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1571049564,
            "sbg:revisionNotes": null
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1571049578,
            "sbg:revisionNotes": "Import"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602061212,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1606727480,
            "sbg:revisionNotes": "CWLtool preparation"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1606727545,
            "sbg:revisionNotes": "CWLtool compatible"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608562910,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608905811,
            "sbg:revisionNotes": "New docker"
          }
        ],
        "sbg:license": "Apache License 2.0",
        "sbg:categories": [
          "Other"
        ],
        "sbg:toolkit": "SBGTools",
        "sbg:toolkitVersion": "1.0",
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-pipelines-dev/sbg-flattenlists/6",
        "sbg:revision": 6,
        "sbg:revisionNotes": "New docker",
        "sbg:modifiedOn": 1608905811,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1571049564,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-pipelines-dev",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic",
          "boris_majic"
        ],
        "sbg:latestRevision": 6,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "a8ab04a2a11a3f02f5cb29025dbeebbe3bb71cc8f1eb7caafb6e2140373cc62f3"
      },
      "label": "SBG FlattenLists",
      "sbg:x": 1140,
      "sbg:y": 497
    },
    {
      "id": "sbg_group_segments",
      "in": [
        {
          "id": "assoc_files",
          "source": [
            "sbg_flattenlists/output_list"
          ]
        }
      ],
      "out": [
        {
          "id": "grouped_assoc_files"
        },
        {
          "id": "chromosome"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-pipelines-dev/sbg-group-segments/14",
        "baseCommand": [
          "echo",
          "\"Grouping\""
        ],
        "inputs": [
          {
            "sbg:category": "Inputs",
            "id": "assoc_files",
            "type": "File[]",
            "label": "Assoc files",
            "doc": "Assoc files.",
            "sbg:fileTypes": "RDATA"
          }
        ],
        "outputs": [
          {
            "id": "grouped_assoc_files",
            "type": [
              "null",
              {
                "type": "array",
                "items": [
                  {
                    "type": "array",
                    "items": [
                      "File",
                      "null"
                    ]
                  },
                  "null"
                ]
              }
            ],
            "outputBinding": {
              "outputEval": "${\n    function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"/\").pop();\n        chrom_num = chrom_num.substr(0,chrom_num.lastIndexOf(\".\")).split('_').slice(0,-1).join('_')\n        if(isNumeric(chrom_num.charAt(chrom_num.length-2)))\n        {\n            chr_array.push(chrom_num.substr(chrom_num.length - 2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(chrom_num.length - 1))\n        }\n        return chr_array.toString()\n    }\n    \n    var assoc_files_dict = {};\n    var grouped_assoc_files = [];\n    var chr;\n    for(var i=0; i<inputs.assoc_files.length; i++){\n        chr = find_chromosome(inputs.assoc_files[i].path)\n        if(chr in assoc_files_dict){\n            assoc_files_dict[chr].push(inputs.assoc_files[i])\n        }\n        else{\n            assoc_files_dict[chr] = [inputs.assoc_files[i]]\n        }\n    }\n    for(var key in assoc_files_dict){\n        grouped_assoc_files.push(assoc_files_dict[key])\n    }\n    return grouped_assoc_files\n    \n}"
            }
          },
          {
            "id": "chromosome",
            "doc": "Chromosomes.",
            "label": "Chromosomes",
            "type": "string[]?",
            "outputBinding": {
              "outputEval": "${\n    function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"/\").pop();\n        chrom_num = chrom_num.substr(0,chrom_num.lastIndexOf(\".\")).split('_').slice(0,-1).join('_')\n        if(isNumeric(chrom_num.charAt(chrom_num.length-2)))\n        {\n            chr_array.push(chrom_num.substr(chrom_num.length - 2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(chrom_num.length - 1))\n        }\n        return chr_array.toString()\n    }\n    \n    var assoc_files_dict = {};\n    var output_chromosomes = [];\n    var chr;\n    for(var i=0; i<inputs.assoc_files.length; i++){\n        chr = find_chromosome(inputs.assoc_files[i].path)\n        if(chr in assoc_files_dict){\n            assoc_files_dict[chr].push(inputs.assoc_files[i])\n        }\n        else{\n            assoc_files_dict[chr] = [inputs.assoc_files[i]]\n        }\n    }\n    for(var key in assoc_files_dict){\n        output_chromosomes.push(key)\n    }\n    return output_chromosomes\n    \n}"
            }
          }
        ],
        "label": "SBG Group Segments",
        "requirements": [
          {
            "class": "DockerRequirement",
            "dockerPull": "uwgac/topmed-master:2.8.1"
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
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1571049664,
            "sbg:revisionNotes": null
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1571049672,
            "sbg:revisionNotes": "Import"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583406613,
            "sbg:revisionNotes": "find_chromosome function updated"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583493406,
            "sbg:revisionNotes": "find_chromosome function updated2"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583500580,
            "sbg:revisionNotes": "Version 1"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583511231,
            "sbg:revisionNotes": "Corrected for GDS name"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583852790,
            "sbg:revisionNotes": "Revision 1 - Import"
          },
          {
            "sbg:revision": 7,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602061140,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 8,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1606727904,
            "sbg:revisionNotes": "CWLtool preparation"
          },
          {
            "sbg:revision": 9,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608561627,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 10,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608563954,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 11,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608630482,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 12,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608630499,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 13,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608729995,
            "sbg:revisionNotes": "CWLtool prep"
          },
          {
            "sbg:revision": 14,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608905828,
            "sbg:revisionNotes": "New docker"
          }
        ],
        "sbg:image_url": null,
        "sbg:projectName": "GENESIS pipelines - DEV",
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-pipelines-dev/sbg-group-segments/14",
        "sbg:revision": 14,
        "sbg:revisionNotes": "New docker",
        "sbg:modifiedOn": 1608905828,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1571049664,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-pipelines-dev",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic",
          "boris_majic"
        ],
        "sbg:latestRevision": 14,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "a515be0f5124c62e65c743e3ca9940a2d4d90f71217b08949ce69537195ad562c"
      },
      "label": "SBG Group Segments",
      "sbg:x": 1330,
      "sbg:y": 497
    },
    {
      "id": "assoc_combine_r",
      "in": [
        {
          "id": "chromosome",
          "source": [
            "sbg_group_segments/chromosome"
          ],
          "valueFrom": "$(self ? [].concat(self) : self)"
        },
        {
          "id": "assoc_type",
          "default": "aggregate"
        },
        {
          "id": "assoc_files",
          "source": [
            "sbg_group_segments/grouped_assoc_files"
          ],
          "valueFrom": "$(self ? [].concat(self) : self)"
        }
      ],
      "out": [
        {
          "id": "assoc_combined"
        },
        {
          "id": "configs"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-toolkit-demo/assoc-combine-r/14",
        "baseCommand": [],
        "inputs": [
          {
            "sbg:altPrefix": "-c",
            "sbg:category": "Optional inputs",
            "id": "chromosome",
            "type": "string[]?",
            "inputBinding": {
              "prefix": "--chromosome",
              "shellQuote": false,
              "position": 10
            },
            "label": "Chromosome",
            "doc": "Chromosome (1-24 or X,Y)."
          },
          {
            "id": "assoc_type",
            "type": {
              "type": "enum",
              "symbols": [
                "single",
                "aggregate",
                "window"
              ],
              "name": "assoc_type"
            },
            "label": "Association Type",
            "doc": "Type of association test: single, window or aggregate."
          },
          {
            "id": "assoc_files",
            "type": "File[]",
            "label": "Association files",
            "doc": "Association files to be combined.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "id": "out_prefix",
            "type": "string?",
            "label": "Out Prefix",
            "doc": "Output prefix."
          },
          {
            "sbg:category": "Input options",
            "sbg:toolDefaultValue": "4",
            "id": "memory_gb",
            "type": "float?",
            "label": "memory GB",
            "doc": "Memory in GB per one job. Default value: 4GB."
          },
          {
            "sbg:category": "Input Options",
            "sbg:toolDefaultValue": "1",
            "id": "cpu",
            "type": "int?",
            "label": "CPU",
            "doc": "Number of CPUs for each tool job. Default value: 1."
          },
          {
            "sbg:category": "General",
            "id": "conditional_variant_file",
            "type": "File?",
            "label": "Conditional variant file",
            "doc": "RData file with data frame of of conditional variants. Columns should include chromosome (or chr) and variant.id. The alternate allele dosage of these variants will be included as covariates in the analysis.",
            "sbg:fileTypes": "RData, RDATA"
          }
        ],
        "outputs": [
          {
            "id": "assoc_combined",
            "doc": "Assoc combined.",
            "label": "Assoc combined",
            "type": "File?",
            "outputBinding": {
              "glob": "${\n    \n    //var input_files = [].concat(inputs.assoc_files);\n    //var first_filename = input_files[0].basename;\n    \n    //var chr = first_filename.split('_chr')[1].split('_')[0].split('.RData')[0];\n    \n    //return first_filename.split('chr')[0]+'chr'+chr+'.RData';\n    \n    return '*.RData'\n}",
              "outputEval": "$(inheritMetadata(self, inputs.assoc_files))"
            },
            "sbg:fileTypes": "RDATA"
          },
          {
            "id": "configs",
            "doc": "Config files.",
            "label": "Config files",
            "type": "File[]?",
            "outputBinding": {
              "glob": "*config*"
            },
            "sbg:fileTypes": "CONFIG"
          }
        ],
        "label": "assoc_combine.R",
        "arguments": [
          {
            "prefix": "",
            "shellQuote": false,
            "position": 100,
            "valueFrom": "assoc_combine.config"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 5,
            "valueFrom": "Rscript /usr/local/analysis_pipeline/R/assoc_combine.R"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 1,
            "valueFrom": "${\n    var command = '';\n    var i;\n    for(i=0; i<inputs.assoc_files.length; i++)\n        command += \"ln -s \" + inputs.assoc_files[i].path + \" \" + inputs.assoc_files[i].path.split(\"/\").pop() + \" && \"\n    \n    return command\n}"
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
            "ramMin": "${\n    if(inputs.memory_gb)\n        return parseInt(inputs.memory_gb * 1024)\n    else\n        return 4*1024\n}",
            "coresMin": "${ if(inputs.cpu)\n        return inputs.cpu \n    else \n        return 1\n}"
          },
          {
            "class": "DockerRequirement",
            "dockerPull": "uwgac/topmed-master:2.8.1"
          },
          {
            "class": "InitialWorkDirRequirement",
            "listing": [
              {
                "entryname": "assoc_combine.config",
                "entry": "${\n    var argument = [];\n    argument.push('assoc_type \"'+ inputs.assoc_type + '\"');\n    var data_prefix = inputs.assoc_files[0].basename.split('_chr')[0];\n    if (inputs.out_prefix)\n    {\n        argument.push('out_prefix \"' + inputs.out_prefix+ '\"');\n    }\n    else\n    {\n        argument.push('out_prefix \"' + data_prefix+ '\"');\n    }\n    \n    if(inputs.conditional_variant_file){\n        argument.push('conditional_variant_file \"' + inputs.conditional_variant_file.path + '\"');\n    }\n    //if(inputs.assoc_files)\n    //{\n    //    arguments.push('assoc_files \"' + inputs.assoc_files[0].path + '\"')\n    //}\n    return argument.join('\\n') + '\\n'\n}",
                "writable": false
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
            "sbg:modifiedOn": 1570638129,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/0"
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1573739976,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/1"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583403361,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/2"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583500657,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/3"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583504951,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/4"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583507194,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/5"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583774238,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/6"
          },
          {
            "sbg:revision": 7,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583870141,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/7"
          },
          {
            "sbg:revision": 8,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593600086,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/8"
          },
          {
            "sbg:revision": 9,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593621244,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/9"
          },
          {
            "sbg:revision": 10,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602060526,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/10"
          },
          {
            "sbg:revision": 11,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602065180,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/11"
          },
          {
            "sbg:revision": 12,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1603722208,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/12"
          },
          {
            "sbg:revision": 13,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1606728652,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/13"
          },
          {
            "sbg:revision": 14,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608570708,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/14"
          }
        ],
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-toolkit-demo/assoc-combine-r/14",
        "sbg:revision": 14,
        "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-combine-r/14",
        "sbg:modifiedOn": 1608570708,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1570638129,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-toolkit-demo",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic",
          "boris_majic"
        ],
        "sbg:latestRevision": 14,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "af0bb74ff0be18115520a67d15107d6f1f0767775b6cd62f7a9c39fa0eb8f12da",
        "sbg:copyOf": "boris_majic/genesis-toolkit-dev/assoc-combine-r/14"
      },
      "label": "Association Combine",
      "scatter": [
        "chromosome",
        "assoc_files"
      ],
      "scatterMethod": "dotproduct",
      "sbg:x": 1560,
      "sbg:y": 499
    },
    {
      "id": "assoc_plots",
      "in": [
        {
          "id": "assoc_files",
          "linkMerge": "merge_flattened",
          "source": [
            "assoc_combine_r/assoc_combined"
          ],
          "valueFrom": "$(self ? [].concat(self) : self)"
        },
        {
          "id": "assoc_type",
          "default": "aggregate"
        },
        {
          "id": "plots_prefix",
          "source": "out_prefix"
        },
        {
          "id": "disable_thin",
          "source": "disable_thin"
        },
        {
          "id": "thin_npoints",
          "source": "thin_npoints"
        },
        {
          "id": "thin_nbins",
          "source": "thin_nbins"
        },
        {
          "id": "plot_mac_threshold",
          "source": "plot_mac_threshold"
        },
        {
          "id": "truncate_pval_threshold",
          "source": "truncate_pval_threshold"
        }
      ],
      "out": [
        {
          "id": "assoc_plots"
        },
        {
          "id": "configs"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-toolkit-demo/assoc-plots/10",
        "baseCommand": [],
        "inputs": [
          {
            "sbg:category": "Input Files",
            "id": "assoc_files",
            "type": "File[]",
            "label": "Association File",
            "doc": "Association File.",
            "sbg:fileTypes": "RDATA"
          },
          {
            "sbg:category": "Input options",
            "id": "assoc_type",
            "type": [
              "null",
              {
                "type": "enum",
                "symbols": [
                  "single",
                  "window",
                  "aggregate"
                ],
                "name": "assoc_type"
              }
            ],
            "label": "Association Type",
            "doc": "Type of association test: single, window or aggregate"
          },
          {
            "sbg:toolDefaultValue": "1-23",
            "sbg:category": "Input options",
            "id": "chromosomes",
            "type": "string?",
            "label": "Chromosomes",
            "doc": "List of chromosomes. If not provided, in case of multiple files, it will be automatically generated with assumtion that files are in format *chr*.RData\nExample: 1 2 3"
          },
          {
            "sbg:toolDefaultValue": "plots",
            "sbg:category": "Input Options",
            "id": "plots_prefix",
            "type": "string?",
            "label": "Plots prefix",
            "doc": "Prefix for plot files."
          },
          {
            "sbg:category": "Input Options",
            "id": "disable_thin",
            "type": "boolean?",
            "label": "Disable Thin",
            "doc": "Logical for whether to thin points in the PC-variant correlation plots. By default, thin is set to TRUE. This parameter disables it."
          },
          {
            "sbg:category": "Inputs",
            "id": "known_hits_file",
            "type": "File?",
            "label": "Known hits file",
            "doc": "RData file with data.frame containing columns chr and pos. If provided, 1 Mb regions surrounding each variant listed will be omitted from the QQ and manhattan plots.",
            "sbg:fileTypes": "RData, RDATA"
          },
          {
            "sbg:category": "General",
            "sbg:toolDefaultValue": "10000",
            "id": "thin_npoints",
            "type": "int?",
            "label": "Thin N points",
            "doc": "Number of points in each bin after thinning. Default: 10000"
          },
          {
            "sbg:toolDefaultValue": "10",
            "sbg:category": "General",
            "id": "thin_nbins",
            "type": "int?",
            "label": "Thin N bins",
            "doc": "Number of bins to use for thinning. Default: 10."
          },
          {
            "id": "plot_mac_threshold",
            "type": "int?",
            "label": "Plot MAC threshold",
            "doc": "Plot MAC threshold."
          },
          {
            "id": "truncate_pval_threshold",
            "type": "float?",
            "label": "Truncate pval threshold",
            "doc": "Truncate pval threshold."
          }
        ],
        "outputs": [
          {
            "id": "assoc_plots",
            "doc": "QQ and Manhattan Plots generated by assoc_plots.R script.",
            "label": "Assoc plots",
            "type": "File[]?",
            "outputBinding": {
              "glob": "*.png"
            },
            "sbg:fileTypes": "PNG"
          },
          {
            "id": "configs",
            "doc": "Config files.",
            "label": "Config files",
            "type": "File[]?",
            "outputBinding": {
              "glob": "*config*"
            },
            "sbg:fileTypes": "CONFIG"
          }
        ],
        "label": "assoc_plots.R",
        "arguments": [
          {
            "prefix": "",
            "shellQuote": false,
            "position": 5,
            "valueFrom": "assoc_file.config"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 3,
            "valueFrom": "Rscript /usr/local/analysis_pipeline/R/assoc_plots.R"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 1,
            "valueFrom": "${\n    var command = '';\n    var i;\n    for(i=0; i<inputs.assoc_files.length; i++)\n        command += \"ln -s \" + inputs.assoc_files[i].path + \" \" + inputs.assoc_files[i].path.split(\"/\").pop() + \" && \"\n    \n    return command\n}"
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
            "ramMin": 64000,
            "coresMin": 1
          },
          {
            "class": "DockerRequirement",
            "dockerPull": "uwgac/topmed-master:2.8.1"
          },
          {
            "class": "InitialWorkDirRequirement",
            "listing": [
              {
                "entryname": "assoc_file.config",
                "entry": "${\n    function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    \n    function find_chromosome(file){\n        var chr_array = [];\n        var chrom_num = file.split(\"chr\")[1];\n        \n        if(isNumeric(chrom_num.charAt(1)))\n        {\n            chr_array.push(chrom_num.substr(0,2))\n        }\n        else\n        {\n            chr_array.push(chrom_num.substr(0,1))\n        }\n        return chr_array.toString()\n    }\n    \n    var argument = [];\n    argument.push('out_prefix \"assoc_single\"');\n    var a_file = [].concat(inputs.assoc_files)[0];\n    var chr = find_chromosome(a_file.basename);\n    var path = a_file.path.split('chr'+chr);\n    var extension = path[1].split('.')[1];\n    \n     \n    if(inputs.plots_prefix){\n        argument.push('plots_prefix ' + inputs.plots_prefix);\n        argument.push('out_file_manh ' + inputs.plots_prefix + '_manh.png');\n        argument.push('out_file_qq ' + inputs.plots_prefix + '_qq.png');\n    }\n    else{\n        var data_prefix = path[0].split('/').pop();\n        argument.push('out_file_manh ' + data_prefix + 'manh.png');\n        argument.push('out_file_qq ' + data_prefix + 'qq.png');\n        argument.push('plots_prefix \"plots\"')\n    }\n    if(inputs.assoc_type){\n        argument.push('assoc_type ' + inputs.assoc_type)\n    }\n    \n    argument.push('assoc_file ' + '\"' + path[0].split('/').pop() + 'chr ' +path[1] + '\"')\n\n    if(inputs.chromosomes){\n        argument.push('chromosomes \"' + inputs.chromosomes + '\"')\n    }\n    else {\n        var chr_array = [];\n        var chrom_num;\n        var i;\n        for (var i = 0; i < inputs.assoc_files.length; i++) \n        {\n            chrom_num = inputs.assoc_files[i].path.split(\"/\").pop()\n            chrom_num = find_chromosome(chrom_num)\n            \n            chr_array.push(chrom_num)\n        }\n        \n        chr_array = chr_array.sort(function(a, b) { a.localeCompare(b, 'en', {numeric: true, ignorePunctuation: true})})\n        \n        var chrs = \"\";\n        for (var i = 0; i < chr_array.length; i++) \n        {\n            chrs += chr_array[i] + \" \"\n        }\n        argument.push('chromosomes \"' + chrs + '\"')\n    }\n    if(inputs.disable_thin){\n        argument.push('thin FALSE')\n    }\n    if(inputs.thin_npoints)\n        argument.push('thin_npoints ' + inputs.thin_npoints)\n    if(inputs.thin_npoints)\n        argument.push('thin_nbins ' + inputs.thin_nbins)\n    if(inputs.known_hits_file)\n        argument.push('known_hits_file \"' + inputs.known_hits_file.path + '\"')\n    if(inputs.plot_mac_threshold)\n        argument.push('plot_mac_threshold ' + inputs.plot_mac_threshold)  \n    if(inputs.truncate_pval_threshold)\n        argument.push('truncate_pval_threshold ' + inputs.truncate_pval_threshold)    \n        \n    argument.push('\\n')\n    return argument.join('\\n')\n}",
                "writable": false
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
        "sbg:image_url": null,
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1570638136,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/0"
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "boris_majic",
            "sbg:modifiedOn": 1573739980,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/2"
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583429742,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/3"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583499961,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/4"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1583774217,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/5"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593600091,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/6"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1593621240,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/7"
          },
          {
            "sbg:revision": 7,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602060529,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/8"
          },
          {
            "sbg:revision": 8,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602065176,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/9"
          },
          {
            "sbg:revision": 9,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1603727327,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/10"
          },
          {
            "sbg:revision": 10,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1606729581,
            "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/11"
          }
        ],
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-toolkit-demo/assoc-plots/10",
        "sbg:revision": 10,
        "sbg:revisionNotes": "Copy of boris_majic/genesis-toolkit-dev/assoc-plots/11",
        "sbg:modifiedOn": 1606729581,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1570638136,
        "sbg:createdBy": "boris_majic",
        "sbg:project": "boris_majic/genesis-toolkit-demo",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic",
          "boris_majic"
        ],
        "sbg:latestRevision": 10,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "a864fc519aa96ffd19ae69db5e4f0a79af8777882dd1722b2a2299e8c33dd965e",
        "sbg:copyOf": "boris_majic/genesis-toolkit-dev/assoc-plots/11"
      },
      "label": "Association Plots",
      "sbg:x": 1738,
      "sbg:y": 669
    },
    {
      "id": "sbg_gds_renamer",
      "in": [
        {
          "id": "in_variants",
          "source": "input_gds_files"
        }
      ],
      "out": [
        {
          "id": "renamed_variants"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.1",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "boris_majic/genesis-toolkit-demo/sbg-gds-renamer/6",
        "baseCommand": [
          "cp"
        ],
        "inputs": [
          {
            "id": "in_variants",
            "type": "File",
            "label": "GDS input",
            "doc": "This tool removes suffix after 'chr##' in GDS filename. ## stands for chromosome name and can be (1-22,X,Y).",
            "sbg:fileTypes": "GDS"
          }
        ],
        "outputs": [
          {
            "id": "renamed_variants",
            "doc": "Renamed GDS file.",
            "label": "Renamed GDS",
            "type": "File",
            "outputBinding": {
              "glob": "${\n    return '*'+inputs.in_variants.nameext\n}"
            },
            "sbg:fileTypes": "GDS"
          }
        ],
        "doc": "This tool renames GDS file in GENESIS pipelines if they contain suffixes after chromosome (chr##) in the filename.\nFor example: If GDS file has name data_chr1_subset.gds the tool will rename GDS file to data_chr1.gds.",
        "label": "SBG GDS renamer",
        "arguments": [
          {
            "prefix": "",
            "shellQuote": false,
            "position": 0,
            "valueFrom": "${\n    if(inputs.in_variants){\n    return inputs.in_variants.path}\n}"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 0,
            "valueFrom": "${\n     function isNumeric(s) {\n        return !isNaN(s - parseFloat(s));\n    }\n    \n      function find_chromosome(file){\n         var chr_array = [];\n         var chrom_num = file.split(\"chr\")[1];\n        \n         if(isNumeric(chrom_num.charAt(1)))\n         {\n            chr_array.push(chrom_num.substr(0,2))\n         }\n         else\n         {\n            chr_array.push(chrom_num.substr(0,1))\n         }\n         return chr_array.toString()\n    }\n    \n    var chr = find_chromosome(inputs.in_variants.nameroot)\n    var base = inputs.in_variants.nameroot.split('chr'+chr)[0]\n    \n    return base+'chr' + chr + inputs.in_variants.nameext\n  \n}"
          },
          {
            "prefix": "",
            "shellQuote": false,
            "position": 100,
            "valueFrom": "${\n    return ' >> job.out.log'   \n}"
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
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1584028650,
            "sbg:revisionNotes": null
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1584028709,
            "sbg:revisionNotes": ""
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1584359096,
            "sbg:revisionNotes": "Description updated"
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602061103,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1602065019,
            "sbg:revisionNotes": "SaveLogs hint"
          },
          {
            "sbg:revision": 5,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608297151,
            "sbg:revisionNotes": "cp instead of mv due to cwltool compatibility"
          },
          {
            "sbg:revision": 6,
            "sbg:modifiedBy": "dajana_panovic",
            "sbg:modifiedOn": 1608905957,
            "sbg:revisionNotes": "New docker"
          }
        ],
        "sbg:image_url": null,
        "sbg:appVersion": [
          "v1.1"
        ],
        "sbg:id": "boris_majic/genesis-toolkit-demo/sbg-gds-renamer/6",
        "sbg:revision": 6,
        "sbg:revisionNotes": "New docker",
        "sbg:modifiedOn": 1608905957,
        "sbg:modifiedBy": "dajana_panovic",
        "sbg:createdOn": 1584028650,
        "sbg:createdBy": "dajana_panovic",
        "sbg:project": "boris_majic/genesis-toolkit-demo",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "dajana_panovic"
        ],
        "sbg:latestRevision": 6,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "ab721cbd39c33d272c5c42693fb02e02e43d95a3f421f40615cbf79ed023c35cc"
      },
      "label": "SBG GDS renamer",
      "scatter": [
        "in_variants"
      ],
      "sbg:x": 1.592018723487854,
      "sbg:y": -21.0740966796875
    }
  ],
  "hints": [
    {
      "class": "sbg:AWSInstanceType",
      "value": "m4.16xlarge;ebs-gp2;700"
    },
    {
      "class": "sbg:maxNumberOfParallelInstances",
      "value": "8"
    }
  ],
  "requirements": [
    {
      "class": "ScatterFeatureRequirement"
    },
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
      "sbg:modifiedOn": 1574269243,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/aggregate-association-testing/7"
    },
    {
      "sbg:revision": 1,
      "sbg:modifiedBy": "boris_majic",
      "sbg:modifiedOn": 1580990761,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/aggregate-association-testing/8"
    },
    {
      "sbg:revision": 2,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1584128985,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/aggregate-association-testing/21"
    },
    {
      "sbg:revision": 3,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1584129557,
      "sbg:revisionNotes": "Copy of boris_majic/genesis-pipelines-dev/aggregate-association-testing/22"
    },
    {
      "sbg:revision": 4,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1584371995,
      "sbg:revisionNotes": "Final wrap"
    },
    {
      "sbg:revision": 5,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1591621964,
      "sbg:revisionNotes": "Variant group filename updated"
    },
    {
      "sbg:revision": 6,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1593600693,
      "sbg:revisionNotes": "New docker image: 2.8.0"
    },
    {
      "sbg:revision": 7,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1593616890,
      "sbg:revisionNotes": "New docker image 2.8.0"
    },
    {
      "sbg:revision": 8,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1593696305,
      "sbg:revisionNotes": "Input descriptions updated on node level"
    },
    {
      "sbg:revision": 9,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1593697958,
      "sbg:revisionNotes": "Input descriptions at node level"
    },
    {
      "sbg:revision": 10,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1594657995,
      "sbg:revisionNotes": "parseFloat"
    },
    {
      "sbg:revision": 11,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1596548405,
      "sbg:revisionNotes": "Benchmarking updated"
    },
    {
      "sbg:revision": 12,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1596548422,
      "sbg:revisionNotes": "Benchmarking updated"
    },
    {
      "sbg:revision": 13,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1596548605,
      "sbg:revisionNotes": "Benchmarking updated"
    },
    {
      "sbg:revision": 14,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1596548617,
      "sbg:revisionNotes": "Benchmarking updated"
    },
    {
      "sbg:revision": 15,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1600673682,
      "sbg:revisionNotes": "Benchmarking table updated"
    },
    {
      "sbg:revision": 16,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1600673756,
      "sbg:revisionNotes": "Benchmarking table updated"
    },
    {
      "sbg:revision": 17,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602061982,
      "sbg:revisionNotes": "Docker 2.8.1 and SaveLogs hint"
    },
    {
      "sbg:revision": 18,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602069581,
      "sbg:revisionNotes": "SaveLogs update"
    },
    {
      "sbg:revision": 19,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602233470,
      "sbg:revisionNotes": "Apps ordering in app settings"
    },
    {
      "sbg:revision": 20,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602253150,
      "sbg:revisionNotes": "Input and output descriptions updated"
    },
    {
      "sbg:revision": 21,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1602747468,
      "sbg:revisionNotes": "Description updated"
    },
    {
      "sbg:revision": 22,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1603796993,
      "sbg:revisionNotes": "Config cleaning"
    },
    {
      "sbg:revision": 23,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1603798375,
      "sbg:revisionNotes": ""
    },
    {
      "sbg:revision": 24,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1603904477,
      "sbg:revisionNotes": "Config cleaning"
    },
    {
      "sbg:revision": 25,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1603963039,
      "sbg:revisionNotes": "Config cleaning"
    },
    {
      "sbg:revision": 26,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1608903567,
      "sbg:revisionNotes": "CWLtool compatible"
    },
    {
      "sbg:revision": 27,
      "sbg:modifiedBy": "dajana_panovic",
      "sbg:modifiedOn": 1608906917,
      "sbg:revisionNotes": "Docker update"
    }
  ],
  "sbg:image_url": null,
  "sbg:toolAuthor": "TOPMed DCC",
  "sbg:license": "MIT",
  "sbg:categories": [
    "GWAS"
  ],
  "sbg:appVersion": [
    "v1.1"
  ],
  "id": "https://api.sb.biodatacatalyst.nhlbi.nih.gov/v2/apps/boris_majic/genesis-pipelines-demo/aggregate-association-testing/27/raw/",
  "sbg:id": "boris_majic/genesis-pipelines-demo/aggregate-association-testing/27",
  "sbg:revision": 27,
  "sbg:revisionNotes": "Docker update",
  "sbg:modifiedOn": 1608906917,
  "sbg:modifiedBy": "dajana_panovic",
  "sbg:createdOn": 1574269243,
  "sbg:createdBy": "boris_majic",
  "sbg:project": "boris_majic/genesis-pipelines-demo",
  "sbg:sbgMaintained": false,
  "sbg:validationErrors": [],
  "sbg:contributors": [
    "dajana_panovic",
    "boris_majic"
  ],
  "sbg:latestRevision": 27,
  "sbg:publisher": "sbg",
  "sbg:content_hash": "aa357d64e1e2ea33b2b4fcd47cc2cd4e2c5c5c6788563cbafb03896f2a42cc14c"
}