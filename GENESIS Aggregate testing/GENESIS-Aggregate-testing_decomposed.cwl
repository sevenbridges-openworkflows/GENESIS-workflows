class: Workflow
cwlVersion: v1.1
doc: |-
  **Aggregate Association Testing workflow** runs aggregate association tests, using Burden, SKAT [1], fastSKAT [2], SMMAT [3], or SKAT-O [4] to aggregate a user-defined set of variants. Association tests are parallelized by segments within chromosomes.

  Define segments splits the genome into segments and assigns each aggregate unit to a segment based on the position of its first variant. Note that number of segments refers to the whole genome, not a number of segments per chromosome. Association testing is then for each segment in parallel, before combining results on chromosome level. Finally, the last step creates QQ and Manhattan plots.

  Aggregate tests are typically used to jointly test rare variants. The **Alt freq max** parameter allows specification of the maximum alternate allele frequency allowable for inclusion in the test. Included variants are usually weighted using either a function of allele frequency (specified via the **Weight Beta** parameter) or some other annotation information (specified via the **Variant weight file** and **Weight user** parameters). 

  When running a burden test, the effect estimate is for each additional unit of burden; there are no effect size estimates for the other tests. Multiple alternate alleles for a single variant are treated separately.

  This workflow utilizes the *assocTestAggregate* function from the GENESIS software.


  ### Common Use Cases
   * This workflow is designed to perform multi-variant association testing on a user-defined groups of variants.


  ### Common Issues and important notes:
  * This pipeline expects that **GDS Files**, **Variant Include Files**, and **Variant group files** are separated per chromosome, and that files are properly named. It is expected that chromosome is included in the filename in following format: chr## , where ## is the name of the chromosome (1-24 or X, Y). Chromosome can be included at any part of the filename.  Examples: data_subset_chr1.vcf,  data_chr1_subset.vcf, chr1_data_subset.vcf.

  * If **Weight Beta** parameter is set, it needs to follow proper convention, two space-delimited floating point numbers.

  * **Number of segments** parameter, if provided, needs to be equal or higher than number of chromosomes.

  * Testing showed that default parameters for **CPU** and **memory GB** (8GB) are sufficient for testing studies (up to 50k samples), however different null models might increase the requirements.

  ### Performance Benchmarking

  In the following table you can find estimates of running time and cost. 

  | Samples &nbsp; &nbsp;|  | Rel. matrix in NM &nbsp; &nbsp; | Test &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;   | Parallel instances &nbsp; &nbsp;| Instance type &nbsp; &nbsp;| Instance  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp;  | CPU &nbsp; &nbsp; | RAM (GB) &nbsp; &nbsp;| Time    &nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp;  | Cost |
  | ------- | -------- | -------------------- | ------ | --------------------- | ---------------- | ------------- | --- | -------- | ----------- | ---- |
  | 10K     |        | w/o                  | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 11 min | 16$  |
  | 10K     |         | Sparse               | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 10min  | 17$  |
  | 10K     |         | Dense                | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 12 min | 16$  |
  | 36K     |         | w/o                  | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 46 min | 28$  |
  | 36K     |         | Sparse               | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 9        | 1 h, 50 min | 31$  |
  | 36K     |         | Dense                | Burden | 8                     | On Dm            | r5.12xlarge   | 4   | 36       | 2h, 59 min  | 66$  |
  | 50K     |         | w/o                  | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 2 h, 28 min | 40$  |
  | 50K     |         | Sparse               | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 9        | 2 h, 11 min | 43$  |
  | 50K     |         | Dense                | Burden | 8                     | On Dm            | r5.24xlarge   | 8   | 70       | 4 h, 47 min | 208$ |
  | 50K     |         | Dense                | Burden | 8                     | On Dm            | r5.24xlarge   | 8   | 70       | 4 h, 30 min | 218$ |
  | 50K     |         | Dense                | Burden | 8                     | On Dm            | r5.24xlarge   | 8   | 70       | 9 h         | 218$ |
  | 10K     |         | w/o                  | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 1 h, 55 min | 16$  |
  | 10K     |         | Sparse               | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 2 h         | 17$  |
  | 10K     |         | Dense                | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 2 h, 40 min | 16$  |
  | 36K     |         | w/o                  | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 2 h, 17 min | 30$  |
  | 36K     |         | Sparse               | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 9        | 2 h, 30 min | 30$  |
  | 36K     |         | Dense                | Burden | 8                     | On Dm            | n1-highmem-32 | 4   | 36       | 6 h         | 91$  |
  | 50K     |         | w/o                  | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 5 h, 50 min | 43$  |
  | 50K     |         | Sparse               | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 9        | 5 h, 50 min | 40$  |
  | 50K     |         | Dense                | Burden | 8                     | On Dm            | n1-highmem-96 | 8   | 70       | 6 h         | 270$ |     
  | 10K |  | w/o    | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min | 16$  |
  | 10K |  | Sparse | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min | 17$  |
  | 10K |  | Dense  | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 17 min | 17$  |
  | 36K |  | w/o    | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 47 min | 27$  |
  | 36K |  | Sparse | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 1 h, 50 min | 31$  |
  | 36K |  | Dense  | SKAT | 8 | On Dm | r5.12xlarge   | 6  | 48  | 5 h, 5 min  | 110$ |
  | 50K |  | w/o    | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 2 h, 27 min | 40$  |
  | 50K |  | Sparse | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 2 h, 23 min | 44$  |
  | 50K |  | Dense  | SKAT | 8 | On Dm | r5.24xlarge   | 13 | 100 | 11 h, 2 min | 500$ |
  | 50K |  | Dense  | SKAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 9 h         | 435$ |
  | 50K |  | Dense  | SKAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 18 h        | 435$ |
  | 10K |  | w/o    | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h, 50 min | 17$  |
  | 10K |  | Sparse | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h         | 16$  |
  | 10K |  | Dense  | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 50 min | 17$  |
  | 36K |  | w/o    | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 45 min | 30$  |
  | 36K |  | Sparse | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 2 h, 20 min | 30$  |
  | 36K |  | Dense  | SKAT | 8 | On Dm | n1-highmem-32 | 6  | 48  | 12 h        | 162$ |
  | 50K |  | w/o    | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 5 h         | 45$  |
  | 50K |  | Sparse | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 5 h         | 45$  |
  | 50K |  | Dense  | SKAT | 8 | On Dm | n1-highmem-96 | 13 | 100 | 14 h        | 620$ |
  | 50K |  | Dense  | SKAT | 8 | On Dm | n1-highmem-96 | 12 | 90  | 14 h        | 620$ |
  | 10K |  | w/o    | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min  | 16$  |
  | 10K |  | Sparse | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 16 min  | 16$  |
  | 10K |  | Dense  | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 18 min  | 17$  |
  | 36K |  | w/o    | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 45 min  | 28$  |
  | 36K |  | Sparse | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 1 h, 48 min  | 32$  |
  | 36K |  | Dense  | SMMAT | 8 | On Dm | r5.12xlarge   | 6  | 48  | 5h           | 111$ |
  | 50K |  | w/o    | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 2 h, 30 min  | 40$  |
  | 50K |  | Sparse | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 2 h, 47 min  | 44$  |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 13 | 100 | 11 h, 30 min | 500$ |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 9 h          | 435$ |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 18 h         | 435$ |
  | 10K |  | w/o    | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h 30 min   | 15$  |
  | 10K |  | Sparse | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h          | 16$  |
  | 10K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 50 min  | 17$  |
  | 36K |  | w/o    | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 43 min  | 30$  |
  | 36K |  | Sparse | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 2 h, 25 min  | 30$  |
  | 36K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-32 | 6  | 48  | 12 h         | 160$ |
  | 50K |  | w/o    | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 5 h          | 42$  |
  | 50K |  | Sparse | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 5 h          | 50$  |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-96 | 13 | 100 | 14 h         | 620$ |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-96 | 12 | 90  | 14 h         | 620$ |
  | 10K |  | w/o    | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 14 min  | 16$  |
  | 10K |  | Sparse | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min  | 16$  |
  | 10K |  | Dense  | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 17 min  | 17$  |
  | 36K |  | w/o    | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 50 min  | 28$  |
  | 36K |  | Sparse | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 1 h, 40 min  | 34$  |
  | 36K |  | Dense  | Fast SKAT | 8 | On Dm | r5.12xlarge   | 6  | 50  | 5 h, 30 min  | 135$ |
  | 50K |  | w/o    | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 10  | 1 h, 30 min  | 40$  |
  | 50K |  | Sparse | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 10  | 1 h, 30 min  | 43$  |
  | 50K |  | Dense  | Fast SKAT | 8 | On Dm | r5.24xlarge   | 13 | 100 | 11 h, 41 min | 501$ |
  | 10K |  | w/o    | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h, 30 min  | 16$  |
  | 10K |  | Sparse | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h, 30 min  | 16$  |
  | 10K |  | Dense  | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 50 min  | 17$  |
  | 36K |  | w/o    | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 3 h          | 30$  |
  | 36K |  | Sparse | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 4 h, 30min   | 32$  |
  | 36K |  | Dense  | Fast SKAT | 8 | On Dm | n1-highmem-32 | 6  | 50  | 11 h         | 160$ |
  | 50K |  | w/o    | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 10  | 3 h          | 45$  |
  | 50K |  | Sparse | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 10  | 3 h          | 45$  |
  | 50K |  | Dense  | Fast SKAT | 8 | On Dm | n1-highmem-96 | 13 | 100 | 14 h         | 650$ |

  In tests performed we used **1000G** (tasks with 2.5k participants) and **TOPMed freeze5** datasets (tasks with 10k or more participants). All these tests are done with applied **MAF < 1% filter.** There are **70 mio** variants with MAF <= 1% in **1000G** and **460 mio** in **TOPMed freeze5 dataset**. Typically, aggregate tests only use a subset of these variants; e.g. grouped by gene. Computational performance will vary depending on how many total variants are tested, and how many variants are included in each aggregation unit.

  *For more details on **spot/preemptible instances** please visit the [Knowledge Center](https://docs.sevenbridges.com/docs/about-spot-instances).*     

  ### API Python Implementation

  The app's draft task can also be submitted via the **API**. In order to learn how to get your **Authentication token** and **API endpoint** for the corresponding Platform visit our [documentation](https://github.com/sbg/sevenbridges-python#authentication-and-configuration).

  ```python
  from sevenbridges import Api

  authentication_token, api_endpoint = "enter_your_token", "enter_api_endpoint"
  api = Api(token=authentication_token, url=api_endpoint)
  # Get project_id/app_id from your address bar. Example: https://f4c.sbgenomics.com/u/your_username/project/app
  project_id, app_id = "your_username/project", "your_username/project/app"
  # Get file names from files in your project. Example: Names are taken from Data/Public Reference Files.
  inputs = {
      "input_gds_files": api.files.query(project=project_id, names=["basename_chr1.gds", "basename_chr2.gds", ..]),
      "variant_group_files": api.files.query(project=project_id, names=["variant_group_chr1.RData", "variant_group_chr2.RData", ..]),
      "phenotype_file": api.files.query(project=project_id, names=["name_of_phenotype_file"])[0],
      "null_model_file": api.files.query(project=project_id, names=["name_of_null_model_file"])[0]
  }
  task = api.tasks.create(name='Aggregate Association Testing - API Run', project=project_id, app=app_id, inputs=inputs, run=False)
  ```
  Instructions for installing and configuring the API Python client, are provided on [github](https://github.com/sbg/sevenbridges-python#installation). For more information about using the API Python client, consult [sevenbridges-python documentation](http://sevenbridges-python.readthedocs.io/en/latest/). **More examples** are available [here](https://github.com/sbg/okAPI).

  Additionally, [API R](https://github.com/sbg/sevenbridges-r) and [API Java](https://github.com/sbg/sevenbridges-java) clients are available. To learn more about using these API clients please refer to the [API R client documentation](https://sbg.github.io/sevenbridges-r/), and [API Java client documentation](https://docs.sevenbridges.com/docs/java-library-quickstart).


  ### References
  [1] [SKAT](https://dx.doi.org/10.1016%2Fj.ajhg.2011.05.029)  
  [2] [fastSKAT](https://doi.org/10.1002/gepi.22136)  
  [3] [SMMAT](https://doi.org/10.1016/j.ajhg.2018.12.012)  
  [4] [SKAT-O](https://doi.org/10.1093/biostatistics/kxs014)  
  [5] [GENESIS](https://f4c.sbgenomics.com/u/boris_majic/genesis-pipelines-dev/apps/doi.org/10.1093/bioinformatics/btz567)
label: Aggregate Association Testing
$namespaces:
  sbg: https://sevenbridges.com
inputs:
- id: segment_length
  type: int?
  label: Segment length
  doc: Segment length in kb, used for parallelization.
  sbg:toolDefaultValue: 10000kb
  sbg:x: -493.4073791503906
  sbg:y: 145.2222900390625
- id: n_segments
  type: int?
  label: Number of segments
  doc: Number of segments, used for parallelization (overrides Segment length). Note
    that this parameter defines the number of segments for the entire genome, so using
    this argument with selected chromosomes may result in fewer segments than you
    expect (and the minimum is one segment per chromosome).
  sbg:x: -499.4447326660156
  sbg:y: 263.33343505859375
- id: genome_build
  type:
  - 'null'
  - type: enum
    symbols:
    - hg19
    - hg38
    name: genome_build
  label: Genome build
  doc: Genome build for the genotypes in the GDS file (hg19 or hg38). Used to divide
    the genome into segments for parallel processing.
  sbg:toolDefaultValue: hg38
  sbg:x: -490.4073791503906
  sbg:y: 387.18524169921875
- id: aggregate_type
  type:
  - 'null'
  - type: enum
    symbols:
    - position
    - allele
    name: aggregate_type
  label: Aggregate type
  doc: Type of aggregate grouping. Options are to select variants by allele (unique
    variants) or position (regions of interest).
  sbg:toolDefaultValue: allele
  sbg:x: -69.71428680419922
  sbg:y: 438.71429443359375
- id: variant_group_files
  sbg:fileTypes: RDATA
  type: File[]
  label: Variant group files
  doc: RData file with data.frame defining aggregate groups. If aggregate_type is
    allele, columns should be group_id, chr, pos, ref, alt. If aggregate_type is position,
    columns should be group_id, chr, start, end. Files may be separated by chromosome
    with ‘chr##’ string corresponding to each GDS file. If Variant Include file is
    specified, groups will be subset to included variants.
  sbg:x: -82.28571319580078
  sbg:y: 124.14286041259766
- id: variant_include_files
  sbg:fileTypes: RDATA
  type: File[]?
  label: Variant Include Files
  doc: RData file(s) with a vector of variant.id to include. Files may be separated
    by chromosome with ‘chr##’ string corresponding to each GDS file. If not provided,
    all variants in the GDS file will be included in the analysis.
  sbg:x: 41.50267791748047
  sbg:y: -170.37432861328125
- id: variant_weight_file
  sbg:fileTypes: RDATA
  type: File?
  label: Variant Weight file
  doc: RData file(s) with data.frame specifying variant weights. Columns should contain
    either variant.id or all of (chr, pos, ref, alt). Files may be separated by chromosome
    with ‘chr##’ string corresponding to each GDS file. If not provided, all variants
    will be given equal weight in the test.
  sbg:x: 475
  sbg:y: -107.42857360839844
- id: weight_user
  type: string?
  label: Weight user
  doc: Name of column in variant_weight_file or variant_group_file containing the
    weight for each variant. Overrides Weight beta.
  sbg:x: 477.8571472167969
  sbg:y: 16.571426391601562
- id: weight_beta
  type: string?
  label: Weight Beta
  doc: Parameters of the Beta distribution used to determine variant weights based
    on minor allele frequency; two space delimited values. "1 1" is flat (uniform)
    weights, "0.5 0.5" is proportional to the Madsen-Browning weights, and "1 25"
    gives the Wu weights. This parameter is ignored if weight_user is provided.
  sbg:toolDefaultValue: 1 1
  sbg:x: 368.8571472167969
  sbg:y: -41.85714340209961
- id: test
  type:
  - 'null'
  - type: enum
    symbols:
    - burden
    - skat
    - smmat
    - fastskat
    - skato
    name: test
  label: Test
  doc: Test to perform. Options are burden, SKAT, SMMAT, fast-SKAT, or SKAT-O.
  sbg:toolDefaultValue: Burden
  sbg:x: 113.71428680419922
  sbg:y: 540
- id: rho
  type: float[]?
  label: Rho
  doc: A numeric value or list of values in range [0,1] specifying the rho parameter
    when test is SKAT-O. 0 is a standard SKAT test, 1 is a burden test, and intermediate
    values are a weighted combination of both.
  sbg:toolDefaultValue: '0'
  sbg:x: 202
  sbg:y: 601.5714721679688
- id: phenotype_file
  sbg:fileTypes: RDATA
  type: File
  label: Phenotype file
  doc: RData file with an AnnotatedDataFrame of phenotypes and covariates. Sample
    identifiers must be in column named “sample.id”. It is recommended to use the
    phenotype file output by the GENESIS Null Model app.
  sbg:x: 116
  sbg:y: 666.7142944335938
- id: pass_only
  type: boolean?
  label: Pass only
  doc: TRUE to select only variants with FILTER=PASS. If FALSE, variants that failed
    the quality filter will be included in the test.
  sbg:toolDefaultValue: 'TRUE'
  sbg:x: 200.42857360839844
  sbg:y: 732.5714111328125
- id: null_model_file
  sbg:fileTypes: RDATA
  type: File
  label: Null model file
  doc: RData file containing a null model object. Run the GENESIS Null Model app to
    create this file.
  sbg:x: 115.85713958740234
  sbg:y: 797.1428833007812
- id: memory_gb
  type: float?
  label: Memory GB
  doc: Memory in GB per job.
  sbg:toolDefaultValue: '8'
  sbg:x: 202.14285278320312
  sbg:y: 859.4285888671875
- id: cpu
  type: int?
  label: CPU
  doc: Number of CPUs for each job.
  sbg:toolDefaultValue: '1'
  sbg:x: 114.57142639160156
  sbg:y: 917
- id: alt_freq_max
  type: float?
  label: Alt Freq Max
  doc: 'Maximum alternate allele frequency of variants to include in the test. Default:
    1 (no filtering of variants by frequency). '
  sbg:toolDefaultValue: '1'
  sbg:x: 203.7142791748047
  sbg:y: 982.5714111328125
- id: disable_thin
  type: boolean?
  label: Disable Thin
  doc: Logical for whether to thin points in the QQ and Manhattan plots. By default,
    points are thinned in dense regions to reduce plotting time. If this parameter
    is set to TRUE, all variant p-values will be included in the plots, and the plotting
    will be very long and memory intensive.
  sbg:x: 1502.486572265625
  sbg:y: 762.502685546875
- id: group_id
  type: string?
  label: Group ID
  doc: Alternate name for group_id column in Variant Group file.
  sbg:x: -85.23925018310547
  sbg:y: 321.7161865234375
- id: thin_nbins
  type: int?
  label: Thin N bins
  doc: Number of bins to use for thinning.
  sbg:toolDefaultValue: '10'
  sbg:x: 1457.91943359375
  sbg:y: 650.1939697265625
- id: thin_npoints
  type: int?
  label: Thin N points
  doc: Number of points in each bin after thinning.
  sbg:toolDefaultValue: '10000'
  sbg:x: 1318.279541015625
  sbg:y: 616.2745971679688
- id: out_prefix
  type: string
  label: Output prefix
  doc: Prefix that will be included in all output files.
  sbg:x: 83.72884368896484
  sbg:y: 1033.336669921875
- id: input_gds_files
  sbg:fileTypes: GDS
  type: File[]
  label: GDS files
  doc: GDS files with genotype data for variants to be tested for association. If
    multiple files are selected, they will be run in parallel. Files separated by
    chromosome are expected to have ‘chr##’ strings indicating chromosome number,
    where ‘##’ can be (1-24, X, Y). Output files for each chromosome will include
    the corresponding chromosome number.
  sbg:x: -206.37063598632812
  sbg:y: -21.074094772338867
- id: truncate_pval_threshold
  type: float?
  label: Truncate pval threshold
  doc: Maximum p-value to display in truncated QQ and manhattan plots.
  sbg:x: 1219.759033203125
  sbg:y: 798.991455078125
- id: plot_mac_threshold
  type: int?
  label: Plot MAC threshold
  doc: Minimum minor allele count for variants or aggregate units to include in plots
    (if different from MAC threshold).
  sbg:x: 1397.79150390625
  sbg:y: 874.508056640625
outputs:
- id: assoc_combined
  outputSource:
  - assoc_combine_r/assoc_combined
  sbg:fileTypes: RDATA
  type: File[]?
  label: Association test results
  doc: RData file with data.frame of association test results (test statistic, p-value,
    etc.) See the documentation of the GENESIS R package for detailed description
    of output.
  sbg:x: 1726.478271484375
  sbg:y: 337.85418701171875
- id: assoc_plots_1
  outputSource:
  - assoc_plots/assoc_plots
  sbg:fileTypes: PNG
  type: File[]?
  label: Association test plots
  doc: QQ and Manhattan Plots of p-values in association test results.
  sbg:x: 1866.478271484375
  sbg:y: 505.85418701171875
steps:
  define_segments_r:
    in:
    - id: segment_length
      source: segment_length
    - id: n_segments
      source: n_segments
    - id: genome_build
      source: genome_build
    out:
    - id: config
    - id: define_segments_output
    run: steps/define_segments_r.cwl
    label: Define Segments
    sbg:x: -224.14285278320312
    sbg:y: 260.5714416503906
  sbg_prepare_segments:
    in:
    - id: input_gds_files
      source:
      - sbg_gds_renamer/renamed_variants
    - id: segments_file
      source: define_segments_r/define_segments_output
    - id: aggregate_files
      source:
      - aggregate_list/aggregate_list
    - id: variant_include_files
      source:
      - variant_include_files
    out:
    - id: gds_output
    - id: segments
    - id: aggregate_output
    - id: variant_include_output
    run: steps/sbg_prepare_segments.cwl
    label: SBG Prepare Segments
    sbg:x: 264.8571472167969
    sbg:y: 102.57142639160156
  aggregate_list:
    in:
    - id: variant_group_file
      source: variant_group_files
    - id: aggregate_type
      source: aggregate_type
    - id: group_id
      source: group_id
    out:
    - id: aggregate_list
    - id: config_file
    run: steps/aggregate_list.cwl
    label: Aggregate List
    scatter:
    - variant_group_file
    sbg:x: 106.8010025024414
    sbg:y: 349.28460693359375
  assoc_aggregate:
    in:
    - id: gds_file
      linkMerge: merge_flattened
      source:
      - sbg_prepare_segments/gds_output
      valueFrom: '$(self ? [].concat(self)[0] : self)'
    - id: null_model_file
      source: null_model_file
    - id: phenotype_file
      source: phenotype_file
    - id: aggregate_variant_file
      linkMerge: merge_flattened
      source:
      - sbg_prepare_segments/aggregate_output
      valueFrom: '$(self ? [].concat(self)[0] : self)'
    - id: out_prefix
      source: out_prefix
    - id: rho
      source:
      - rho
    - id: segment_file
      linkMerge: merge_flattened
      source:
      - define_segments_r/define_segments_output
      valueFrom: '$(self ? [].concat(self)[0] : self)'
    - id: test
      source: test
    - id: variant_include_file
      linkMerge: merge_flattened
      source:
      - sbg_prepare_segments/variant_include_output
      valueFrom: '$(self ? [].concat(self)[0] : self)'
    - id: weight_beta
      source: weight_beta
    - id: segment
      linkMerge: merge_flattened
      source:
      - sbg_prepare_segments/segments
      valueFrom: '$(self ? [].concat(self)[0] : self)'
    - id: aggregate_type
      source: aggregate_type
    - id: alt_freq_max
      source: alt_freq_max
    - id: pass_only
      source: pass_only
    - id: variant_weight_file
      source: variant_weight_file
    - id: weight_user
      source: weight_user
    - id: cpu
      source: cpu
    - id: memory_gb
      source: memory_gb
    - id: genome_build
      source: genome_build
    out:
    - id: assoc_aggregate
    - id: config
    run: steps/assoc_aggregate.cwl
    label: Aggregate Association Test
    scatter:
    - gds_file
    - aggregate_variant_file
    - variant_include_file
    - segment
    scatterMethod: dotproduct
    sbg:x: 767.2857666015625
    sbg:y: 436.4285583496094
  sbg_flattenlists:
    in:
    - id: input_list
      source:
      - assoc_aggregate/assoc_aggregate
      valueFrom: ${     var out = [];     for (var i = 0; i<self.length; i++){         if
        (self[i])    out.push(self[i])     }     return out }
    out:
    - id: output_list
    run: steps/sbg_flattenlists.cwl
    label: SBG FlattenLists
    sbg:x: 1140
    sbg:y: 497
  sbg_group_segments:
    in:
    - id: assoc_files
      source:
      - sbg_flattenlists/output_list
    out:
    - id: grouped_assoc_files
    - id: chromosome
    run: steps/sbg_group_segments.cwl
    label: SBG Group Segments
    sbg:x: 1330
    sbg:y: 497
  assoc_combine_r:
    in:
    - id: chromosome
      source:
      - sbg_group_segments/chromosome
      valueFrom: '$(self ? [].concat(self) : self)'
    - id: assoc_type
      default: aggregate
    - id: assoc_files
      source:
      - sbg_group_segments/grouped_assoc_files
      valueFrom: '$(self ? [].concat(self) : self)'
    out:
    - id: assoc_combined
    - id: configs
    run: steps/assoc_combine_r.cwl
    label: Association Combine
    scatter:
    - chromosome
    - assoc_files
    scatterMethod: dotproduct
    sbg:x: 1560
    sbg:y: 499
  assoc_plots:
    in:
    - id: assoc_files
      linkMerge: merge_flattened
      source:
      - assoc_combine_r/assoc_combined
      valueFrom: '$(self ? [].concat(self) : self)'
    - id: assoc_type
      default: aggregate
    - id: plots_prefix
      source: out_prefix
    - id: disable_thin
      source: disable_thin
    - id: thin_npoints
      source: thin_npoints
    - id: thin_nbins
      source: thin_nbins
    - id: plot_mac_threshold
      source: plot_mac_threshold
    - id: truncate_pval_threshold
      source: truncate_pval_threshold
    out:
    - id: assoc_plots
    - id: configs
    run: steps/assoc_plots.cwl
    label: Association Plots
    sbg:x: 1738
    sbg:y: 669
  sbg_gds_renamer:
    in:
    - id: in_variants
      source: input_gds_files
    out:
    - id: renamed_variants
    run: steps/sbg_gds_renamer.cwl
    label: SBG GDS renamer
    scatter:
    - in_variants
    sbg:x: 1.592018723487854
    sbg:y: -21.0740966796875
hints:
- class: sbg:AWSInstanceType
  value: m4.16xlarge;ebs-gp2;700
- class: sbg:maxNumberOfParallelInstances
  value: '8'
requirements:
- class: ScatterFeatureRequirement
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
sbg:projectName: GENESIS pipelines - DEMO
sbg:revisionsInfo:
- sbg:revision: 0
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1574269243
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/aggregate-association-testing/7
- sbg:revision: 1
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1580990761
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/aggregate-association-testing/8
- sbg:revision: 2
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584128985
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/aggregate-association-testing/21
- sbg:revision: 3
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584129557
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/aggregate-association-testing/22
- sbg:revision: 4
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584371995
  sbg:revisionNotes: Final wrap
- sbg:revision: 5
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1591621964
  sbg:revisionNotes: Variant group filename updated
- sbg:revision: 6
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593600693
  sbg:revisionNotes: 'New docker image: 2.8.0'
- sbg:revision: 7
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593616890
  sbg:revisionNotes: New docker image 2.8.0
- sbg:revision: 8
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593696305
  sbg:revisionNotes: Input descriptions updated on node level
- sbg:revision: 9
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593697958
  sbg:revisionNotes: Input descriptions at node level
- sbg:revision: 10
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1594657995
  sbg:revisionNotes: parseFloat
- sbg:revision: 11
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1596548405
  sbg:revisionNotes: Benchmarking updated
- sbg:revision: 12
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1596548422
  sbg:revisionNotes: Benchmarking updated
- sbg:revision: 13
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1596548605
  sbg:revisionNotes: Benchmarking updated
- sbg:revision: 14
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1596548617
  sbg:revisionNotes: Benchmarking updated
- sbg:revision: 15
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1600673682
  sbg:revisionNotes: Benchmarking table updated
- sbg:revision: 16
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1600673756
  sbg:revisionNotes: Benchmarking table updated
- sbg:revision: 17
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602061982
  sbg:revisionNotes: Docker 2.8.1 and SaveLogs hint
- sbg:revision: 18
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602069581
  sbg:revisionNotes: SaveLogs update
- sbg:revision: 19
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602233470
  sbg:revisionNotes: Apps ordering in app settings
- sbg:revision: 20
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602253150
  sbg:revisionNotes: Input and output descriptions updated
- sbg:revision: 21
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602747468
  sbg:revisionNotes: Description updated
- sbg:revision: 22
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603796993
  sbg:revisionNotes: Config cleaning
- sbg:revision: 23
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603798375
  sbg:revisionNotes: ''
- sbg:revision: 24
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603904477
  sbg:revisionNotes: Config cleaning
- sbg:revision: 25
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603963039
  sbg:revisionNotes: Config cleaning
- sbg:revision: 26
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1608903567
  sbg:revisionNotes: CWLtool compatible
- sbg:revision: 27
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1608906917
  sbg:revisionNotes: Docker update
sbg:image_url:
sbg:toolAuthor: TOPMed DCC
sbg:license: MIT
sbg:categories:
- GWAS
sbg:appVersion:
- v1.1
id: https://api.sb.biodatacatalyst.nhlbi.nih.gov/v2/apps/boris_majic/genesis-pipelines-demo/aggregate-association-testing/27/raw/
sbg:id: boris_majic/genesis-pipelines-demo/aggregate-association-testing/27
sbg:revision: 27
sbg:revisionNotes: Docker update
sbg:modifiedOn: 1608906917
sbg:modifiedBy: dajana_panovic
sbg:createdOn: 1574269243
sbg:createdBy: boris_majic
sbg:project: boris_majic/genesis-pipelines-demo
sbg:sbgMaintained: false
sbg:validationErrors: []
sbg:contributors:
- dajana_panovic
- boris_majic
sbg:latestRevision: 27
sbg:publisher: sbg
sbg:content_hash: aa357d64e1e2ea33b2b4fcd47cc2cd4e2c5c5c6788563cbafb03896f2a42cc14c
