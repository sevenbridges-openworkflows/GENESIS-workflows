class: Workflow
cwlVersion: v1.1
doc: |-
  **Sliding Window Association Testing workflow** runs sliding-window association tests. It can use Burden, SKAT [1], fastSKAT [2], SMMAT [3], or SKAT-O [4] to aggregate all variants in a window.

  Sliding window Workflow consists of several steps. Define Segments divides genome into segments, either by a number of segments, or by a segment length. Note that number of segments refers to whole genome, not a number of segments per chromosome Association test is then performed for each segment in parallel, before combining results on chromosome level. Final step produces QQ and Manhattan plots.

  Aggregate tests are typically used to jointly test rare variants. The **Alt freq max** parameter allows specification of the maximum alternate allele frequency allowable for inclusion in the test. Included variants are usually weighted using either a function of allele frequency (specified via the **Weight Beta** parameter) or some other annotation information (specified via the **Variant weight file** and **Weight user** parameters). 

  When running a burden test, the effect estimate is for each additional unit of burden; there are no effect size estimates for the other tests. Multiple alternate alleles for a single variant are treated separately.

  This workflow utilizes the *assocTestAggregate* function from the GENESIS software [5].


  ### Common Use Cases

  Sliding Window Association Testing workflow is designed to run multi-variant, sliding window, association tests using GENESIS software. Set of variants on which to run association testing can be reduced by providing **Variant Include Files** - One file per chromosome containing variant IDs for variants on which association testing will be performed.

  ### Changes Introduced by Seven Bridges:

  There are no changes introduced by Seven Bridges.

  ### Common Issues and Important Notes:

  * This workflow expects **GDS** files split by chromosome, and will not work otherwise. If provided, **variant include** files must also be split in the same way. Also GDS and Variant include files should be properly named. It is expected that chromosome is included in the filename in following format: chr## , where ## is the name of the chromosome (1-24 or X, Y). Chromosome can be included at any part of the filename. Examples for GDS: data_subset_chr1.gds, data_chr1_subset.gds. Examples for Variant include files: variant_include_chr1.RData, chr1_variant_include.RData.

  * **Note:** Memory requirements varies drastically based on input size, and on complexity of null model (for example inclusion of **Relatedness Matrix file** when fitting a null model, in *Null Model* workflow). For example, total input size of **GDS Files** of 100GB, requires 80GB of RAM if GRM is used, and 5 GB of RAM if GRM is not used. For this reason, **memory GB** parameter is exposed for users to adjust. If you need help with adjustments, fell free to contact our support. Running out of memory often, but not always, manifests as *error code 137*.

  ### Performance Benchmarking

  In the following table you can find estimates of running time and cost. All samples are aligned against **hg38 human reference** with default options. 

  | Samples &nbsp; &nbsp; |  | Rel. matrix &nbsp; &nbsp;| Test   &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| Parallel instances &nbsp; &nbsp;| Instance type &nbsp; &nbsp; &nbsp;  | Instance   &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;   | CPU &nbsp; &nbsp; | RAM (GB) &nbsp; &nbsp; | Time  &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;  &nbsp; &nbsp;&nbsp; &nbsp;   | Cost |
  | ------- | -------- | -------------------- | ------ | --------------------- | ---------------- | ------------- | --- | -------- | ----------- | ---- |
  | 10K     |          | w/o                  | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 11 min | $16  |
  | 10K     |          | Sparse               | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 10min  | $17  |
  | 10K     |          | Dense                | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 12 min | $16  |
  | 36K     |          | w/o                  | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 1 h, 46 min | $28  |
  | 36K     |          | Sparse               | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 9        | 1 h, 50 min | $31  |
  | 36K     |          | Dense                | Burden | 8                     | On Dm            | r5.12xlarge   | 4   | 36       | 2h, 59 min  | $66  |
  | 50K     |          | w/o                  | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 8        | 2 h, 28 min | $40  |
  | 50K     |          | Sparse               | Burden | 8                     | On Dm            | r5.12xlarge   | 1   | 9        | 2 h, 11 min | $43  |
  | 50K     |          | Dense                | Burden | 8                     | On Dm            | r5.24xlarge   | 8   | 70       | 4 h, 47 min | $208 |
  | 50K     |          | Dense                | Burden | 8                     | On Dm            | r5.24xlarge   | 8   | 70       | 4 h, 30 min | $218 |
  | 50K     |          | Dense                | Burden | 8                     | On Dm            | r5.24xlarge   | 8   | 70       | 9 h         | $218 |
  | 10K     |          | w/o                  | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 1 h, 55 min | $16  |
  | 10K     |          | Sparse               | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 2 h         | $17  |
  | 10K     |          | Dense                | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 2 h, 40 min | $16  |
  | 36K     |         | w/o                  | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 2 h, 17 min | $30  |
  | 36K     |         | Sparse               | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 9        | 2 h, 30 min | $30  |
  | 36K     |         | Dense                | Burden | 8                     | On Dm            | n1-highmem-32 | 4   | 36       | 6 h         | $91  |
  | 50K     |         | w/o                  | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 8        | 5 h, 50 min | $43  |
  | 50K     |         | Sparse               | Burden | 8                     | On Dm            | n1-highmem-32 | 1   | 9        | 5 h, 50 min | $40  |
  | 50K     |         | Dense                | Burden | 8                     | On Dm            | n1-highmem-96 | 8   | 70       | 6 h         | $270 |
  | 10K     |          | w/o    | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min | $16  |
  | 10K     |          | Sparse | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min | $17  |
  | 10K     |          | Dense  | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 17 min | $17  |
  | 36K     |          | w/o    | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 47 min | $27  |
  | 36K     |            | Sparse | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 1 h, 50 min | $31  |
  | 36K     |          | Dense  | SKAT | 8 | On Dm | r5.12xlarge   | 6  | 48  | 5 h, 5 min  | $110 |
  | 50K     |        | w/o    | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 2 h, 27 min | $40  |
  | 50K |            | Sparse | SKAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 2 h, 23 min | $44  |
  | 50K |           | Dense  | SKAT | 8 | On Dm | r5.24xlarge   | 13 | 100 | 11 h, 2 min | $500 |
  | 50K |        | Dense  | SKAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 9 h         | $435 |
  | 50K |        | Dense  | SKAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 18 h        | $435 |
  | 10K |        | w/o    | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h, 50 min | $17  |
  | 10K |        | Sparse | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h         | $16  |
  | 10K |       | Dense  | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 50 min | $17  |
  | 36K |           | w/o    | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 45 min | $30  |
  | 36K |         | Sparse | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 2 h, 20 min | $30  |
  | 36K |           | Dense  | SKAT | 8 | On Dm | n1-highmem-32 | 6  | 48  | 12 h        | $162 |
  | 50K |          | w/o    | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 5 h         | $45  |
  | 50K |           | Sparse | SKAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 5 h         | $45  |
  | 50K |           | Dense  | SKAT | 8 | On Dm | n1-highmem-96 | 13 | 100 | 14 h        | $620 |
  | 50K |      | Dense  | SKAT | 8 | On Dm | n1-highmem-96 | 12 | 90  | 14 h        | $620 |
  | 10K |  | w/o    | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min  | $16  |
  | 10K |  | Sparse | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 16 min  | $16  |
  | 10K |  | Dense  | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 18 min  | $17  |
  | 36K | | w/o    | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 45 min  | $28  |
  | 36K |  | Sparse | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 1 h, 48 min  | $32  |
  | 36K |  | Dense  | SMMAT | 8 | On Dm | r5.12xlarge   | 6  | 48  | 5h           | $111 |
  | 50K |  | w/o    | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 2 h, 30 min  | $40  |
  | 50K |  | Sparse | SMMAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 2 h, 47 min  | $44  |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 13 | 100 | 11 h, 30 min | $500 |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 9 h          | $435 |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 18 h         | $435 |
  | 10K |  | w/o    | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h 30 min   | $15  |
  | 10K |  | Sparse | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h          | $16  |
  | 10K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 50 min  | $17  |
  | 36K |  | w/o    | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 43 min  | $30  |
  | 36K |  | Sparse | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 2 h, 25 min  | $30  |
  | 36K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-32 | 6  | 48  | 12 h         | $160 |
  | 50K |  | w/o    | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 5 h          | $42  |
  | 50K |  | Sparse | SMMAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 5 h          | $50  |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-96 | 13 | 100 | 14 h         | $620 |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | n1-highmem-96 | 12 | 90  | 14 h         | $620 |
  | 50K |  | Dense  | SMMAT | 8 | On Dm | r5.24xlarge   | 12 | 90  | 18 h         | $435 |
  | 10K |  | w/o    | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 14 min  | $16  |
  | 10K |  | Sparse | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 15 min  | $16  |
  | 10K |  | Dense  | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 17 min  | $17  |
  | 36K |  | w/o    | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 8   | 1 h, 50 min  | $28  |
  | 36K |  | Sparse | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 9   | 1 h, 40 min  | $34  |
  | 36K |  | Dense  | Fast SKAT | 8 | On Dm | r5.12xlarge   | 6  | 50  | 5 h, 30 min  | $135 |
  | 50K |  | w/o    | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 10  | 1 h, 30 min  | $40  |
  | 50K | | Sparse | Fast SKAT | 8 | On Dm | r5.12xlarge   | 1  | 10  | 1 h, 30 min  | $43  |
  | 50K |  | Dense  | Fast SKAT | 8 | On Dm | r5.24xlarge   | 13 | 100 | 11 h, 41 min | $501 |
  | 10K |  | w/o    | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h, 30 min  | $16  |
  | 10K |  | Sparse | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 1 h, 30 min  | $16  |
  | 10K |  | Dense  | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 2 h, 50 min  | $17  |
  | 36K |  | w/o    | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 8   | 3 h          | $30  |
  | 36K |  | Sparse | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 9   | 4 h, 30min   | $32  |
  | 36K |  | Dense  | Fast SKAT | 8 | On Dm | n1-highmem-32 | 6  | 50  | 11 h         | $160 |
  | 50K |  | w/o    | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 10  | 3 h          | $45  |
  | 50K |  | Sparse | Fast SKAT | 8 | On Dm | n1-highmem-32 | 1  | 10  | 3 h          | $45  |
  | 50K |  | Dense  | Fast SKAT | 8 | On Dm | n1-highmem-96 | 13 | 100 | 14 h         | $650 |

  In tests performed we used **1000G** (tasks with 2.5k participants) and **TOPMed freeze5** datasets (tasks with 10k or more participants). All these tests are done with applied **MAF < 1% filter, window size 50kb** and **window step 20kb**. The number of variants that have been tested in **1000G** dataset is **175 mio (140k windows, 1k variants/window)**. The number of variants tested in **TOPMed freeze 5** is **1bio variants (140k windows, 7k variants/window)**.

  Please note that we run all tests with default values for window size and window step (meaning 50kb and 20kb respectively). In this set up windows are overlapping and this is why we have so high number of variants tested. 

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
      "phenotype_file": api.files.query(project=project_id, names=["name_of_phenotype_file"])[0],
      "null_model_file": api.files.query(project=project_id, names=["name_of_null_model_file"])[0]
  }
  task = api.tasks.create(name='Sliding Window Association Testing - API Run', project=project_id, app=app_id, inputs=inputs, run=False)
  ```
  Instructions for installing and configuring the API Python client, are provided on [github](https://github.com/sbg/sevenbridges-python#installation). For more information about using the API Python client, consult [sevenbridges-python documentation](http://sevenbridges-python.readthedocs.io/en/latest/). **More examples** are available [here](https://github.com/sbg/okAPI).

  Additionally, [API R](https://github.com/sbg/sevenbridges-r) and [API Java](https://github.com/sbg/sevenbridges-java) clients are available. To learn more about using these API clients please refer to the [API R client documentation](https://sbg.github.io/sevenbridges-r/), and [API Java client documentation](https://docs.sevenbridges.com/docs/java-library-quickstart).


  ### References
  [1] [SKAT](https://dx.doi.org/10.1016%2Fj.ajhg.2011.05.029)  
  [2] [fastSKAT](https://doi.org/10.1002/gepi.22136)  
  [3] [SMMAT](https://doi.org/10.1016/j.ajhg.2018.12.012)  
  [4] [SKAT-O](https://doi.org/10.1093/biostatistics/kxs014)  
  [5] [GENESIS](https://f4c.sbgenomics.com/u/boris_majic/genesis-pipelines-dev/apps/doi.org/10.1093/bioinformatics/btz567)
label: Sliding Window Association Testing
$namespaces:
  sbg: https://sevenbridges.com
inputs:
- id: segment_length
  type: int?
  label: Segment length
  doc: Segment length in kb, used for parallelization.
  sbg:toolDefaultValue: 10000kb
  sbg:x: -320
  sbg:y: -232.00888061523438
- id: n_segments
  type: int?
  label: Number of segments
  doc: Number of segments, used for parallelization (overrides Segment length). Note
    that this parameter defines the number of segments for the entire genome, so using
    this argument with selected chromosomes may result in fewer segments than you
    expect (and the minimum is one segment per chromosome).
  sbg:x: -392.39886474609375
  sbg:y: -102.07991790771484
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
  sbg:x: -315
  sbg:y: 27
- id: variant_include_files
  sbg:fileTypes: RDATA
  type: File[]?
  label: Variant Include Files
  doc: RData file(s) with a vector of variant.id to include. Files may be separated
    by chromosome with ‘chr##’ string corresponding to each GDS file. If not provided,
    all variants in the GDS file will be included in the analysis.
  sbg:x: -9.39886474609375
  sbg:y: -420.9698486328125
- id: window_step
  type: int?
  label: Window step
  doc: Step size of sliding window in kb.
  sbg:toolDefaultValue: 20kb
  sbg:x: -92.55555725097656
  sbg:y: 122.22222137451172
- id: window_size
  type: int?
  label: Window size
  doc: Size of sliding window in kb.
  sbg:toolDefaultValue: 50kb
  sbg:x: -7.44444465637207
  sbg:y: 187
- id: weight_beta
  type: string?
  label: Weight Beta
  doc: Parameters of the Beta distribution used to determine variant weights based
    on minor allele frequency; two space delimited values. "1 1" is flat (uniform)
    weights, "0.5 0.5" is proportional to the Madsen-Browning weights, and "1 25"
    gives the Wu weights. This parameter is ignored if weight_user is provided.
  sbg:toolDefaultValue: 1 1
  sbg:x: -91.44444274902344
  sbg:y: 269.22222900390625
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
  sbg:x: -87.33333587646484
  sbg:y: 426.4444580078125
- id: rho
  type: float[]?
  label: Rho
  doc: A numeric value or list of values in range [0,1] specifying the rho parameter
    when test is SKAT-O. 0 is a standard SKAT test, 1 is a burden test, and intermediate
    values are a weighted combination of both.
  sbg:toolDefaultValue: '0'
  sbg:x: -3
  sbg:y: 490.6666564941406
- id: phenotype_file
  sbg:fileTypes: RDATA
  type: File
  label: Phenotype file
  doc: RData file with an AnnotatedDataFrame of phenotypes and covariates. Sample
    identifiers must be in column named “sample.id”. It is recommended to use the
    phenotype file output by the GENESIS Null Model app.
  sbg:x: -82.66666412353516
  sbg:y: 570.3333129882812
- id: pass_only
  type: boolean?
  label: Pass only
  doc: TRUE to select only variants with FILTER=PASS. If FALSE, variants that failed
    the quality filter will be included in the test.
  sbg:toolDefaultValue: 'TRUE'
  sbg:x: 292.77777099609375
  sbg:y: 313.5555419921875
- id: null_model_file
  sbg:fileTypes: RDATA
  type: File
  label: Null model file
  doc: RData file containing a null model object. Run the GENESIS Null Model app to
    create this file.
  sbg:x: 215.88888549804688
  sbg:y: 399.77777099609375
- id: cpu
  type: int?
  label: CPU
  doc: Number of CPUs for each job.
  sbg:toolDefaultValue: '1'
  sbg:x: 224.77777099609375
  sbg:y: 546.5555419921875
- id: memory_gb
  type: float?
  label: Memory GB
  doc: Memory in GB per each tool job.
  sbg:toolDefaultValue: '8'
  sbg:x: 294
  sbg:y: 456.77777099609375
- id: alt_freq_max
  type: float?
  label: Alt freq max
  doc: 'Maximum alternate allele frequency of variants to include in the test. Default:
    1 (no filtering of variants by frequency).'
  sbg:toolDefaultValue: '1'
  sbg:x: 296.3333435058594
  sbg:y: 615.3333129882812
- id: disable_thin
  type: boolean?
  label: Disable Thin
  doc: Logical for whether to thin points in the QQ and Manhattan plots. By default,
    points are thinned in dense regions to reduce plotting time. If this parameter
    is set to TRUE, all variant p-values will be included in the plots, and the plotting
    will be very long and memory intensive.
  sbg:x: 1414.068115234375
  sbg:y: 445.278076171875
- id: weight_user
  type: string?
  label: Weight user
  doc: Name of column in variant_weight_file or variant_group_file containing the
    weight for each variant. Overrides Weight beta.
  sbg:x: 11.447738647460938
  sbg:y: 345.5047607421875
- id: thin_nbins
  type: int?
  label: Thin N bins
  doc: Number of bins to use for thinning.
  sbg:toolDefaultValue: '10'
  sbg:x: 1204.76611328125
  sbg:y: 327.224609375
- id: thin_npoints
  type: int?
  label: Thin N points
  doc: Number of points in each bin after thinning.
  sbg:toolDefaultValue: '10000'
  sbg:x: 1415.4290771484375
  sbg:y: 350.51202392578125
- id: variant_weight_file
  sbg:fileTypes: RDATA
  type: File?
  label: Variant weight file
  doc: RData file(s) with data.frame specifying variant weights. Columns should contain
    either variant.id or all of (chr, pos, ref, alt). Files may be separated by chromosome
    with ‘chr##’ string corresponding to each GDS file. If not provided, all variants
    will be given equal weight in the test.
  sbg:x: 175
  sbg:y: -464.18048095703125
- id: out_prefix
  type: string
  label: Output prefix
  doc: Prefix that will be included in all output files.
  sbg:x: 84.2520980834961
  sbg:y: 652.6614379882812
- id: input_gds_files
  sbg:fileTypes: GDS
  type: File[]
  label: GDS files
  doc: GDS files with genotype data for variants to be tested for association. If
    multiple files are selected, they will be run in parallel. Files separated by
    chromosome are expected to have ‘chr##’ strings indicating chromosome number,
    where ‘##’ can be (1-24, X, Y). Output files for each chromosome will include
    the corresponding chromosome number.
  sbg:x: -254.47451782226562
  sbg:y: -403.2757568359375
- id: truncate_pval_threshold
  type: float?
  label: Truncate pval threshold
  doc: Maximum p-value to display in truncated QQ and manhattan plots.
  sbg:x: 1198.21923828125
  sbg:y: 522.0147094726562
- id: plot_mac_threshold
  type: int?
  label: Plot MAC threshold
  doc: Minimum minor allele count for variants or aggregate units to include in plots
    (if different from MAC threshold).
  sbg:x: 1106.90234375
  sbg:y: 406
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
  sbg:x: 1608.2303466796875
  sbg:y: -63.54750442504883
- id: assoc_plots_1
  outputSource:
  - assoc_plots/assoc_plots
  sbg:fileTypes: PNG
  type: File[]?
  label: Association test plots
  doc: QQ and Manhattan Plots of p-values in association test results.
  sbg:x: 1770
  sbg:y: 101
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
    sbg:x: -157
    sbg:y: -100
  sbg_prepare_segments:
    in:
    - id: input_gds_files
      source:
      - sbg_gds_renamer/renamed_variants
    - id: segments_file
      source: define_segments_r/define_segments_output
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
    sbg:x: 186
    sbg:y: -193
  assoc_window:
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
    - id: pass_only
      source: pass_only
    - id: window_size
      source: window_size
    - id: window_step
      source: window_step
    - id: variant_weight_file
      source: variant_weight_file
    - id: alt_freq_max
      source: alt_freq_max
    - id: weight_user
      source: weight_user
    - id: memory_gb
      source: memory_gb
    - id: cpu
      source: cpu
    - id: genome_build
      source: genome_build
    out:
    - id: assoc_window
    - id: config_file
    run: steps/assoc_window.cwl
    label: Sliding Window Association Testing
    scatter:
    - gds_file
    - variant_include_file
    - segment
    scatterMethod: dotproduct
    sbg:x: 572
    sbg:y: 51.11111068725586
  sbg_flattenlists:
    in:
    - id: input_list
      source:
      - assoc_window/assoc_window
      valueFrom: |-
        ${
            var out = [];
            for (var i = 0; i<self.length; i++){
                if (self[i])    out.push(self[i])
            }
            return out
        }
    out:
    - id: output_list
    run: steps/sbg_flattenlists.cwl
    label: SBG FlattenLists
    sbg:x: 917.5
    sbg:y: 98
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
    sbg:x: 1123
    sbg:y: 99
  assoc_combine_r:
    in:
    - id: chromosome
      source:
      - sbg_group_segments/chromosome
      valueFrom: '$(self ? [].concat(self) : self)'
    - id: assoc_type
      default: window
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
    sbg:x: 1367.5
    sbg:y: 101
  assoc_plots:
    in:
    - id: assoc_files
      linkMerge: merge_flattened
      source:
      - assoc_combine_r/assoc_combined
      valueFrom: '$(self ? [].concat(self) : self)'
    - id: assoc_type
      default: window
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
    sbg:x: 1610.5
    sbg:y: 238
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
    sbg:x: -73.19473266601562
    sbg:y: -266.9198303222656
hints:
- class: sbg:maxNumberOfParallelInstances
  value: '8'
- class: sbg:AWSInstanceType
  value: r5.12xlarge;ebs-gp2;1024
requirements:
- class: ScatterFeatureRequirement
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
sbg:projectName: GENESIS pipelines - DEMO
sbg:revisionsInfo:
- sbg:revision: 0
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1574269240
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/sliding-window-association-testing/7
- sbg:revision: 1
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1580990756
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/sliding-window-association-testing/8
- sbg:revision: 2
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584128995
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/sliding-window-association-testing/16
- sbg:revision: 3
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584130249
  sbg:revisionNotes: Copy of boris_majic/genesis-pipelines-dev/sliding-window-association-testing/17
- sbg:revision: 4
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584372207
  sbg:revisionNotes: Final wrap
- sbg:revision: 5
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593600751
  sbg:revisionNotes: 'New docker image: 2.8.0'
- sbg:revision: 6
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593616853
  sbg:revisionNotes: Nee docker image 2.8.0
- sbg:revision: 7
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593697819
  sbg:revisionNotes: Input descriptions on node level.
- sbg:revision: 8
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1594658194
  sbg:revisionNotes: parseFloat
- sbg:revision: 9
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1594721902
  sbg:revisionNotes: Cpu requirements added
- sbg:revision: 10
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1597146060
  sbg:revisionNotes: Benchmarking updated
- sbg:revision: 11
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1598430887
  sbg:revisionNotes: Benchmarking updated
- sbg:revision: 12
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1598431157
  sbg:revisionNotes: Benchmarking updated
- sbg:revision: 13
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1600674807
  sbg:revisionNotes: Benchmarking table updated
- sbg:revision: 14
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602061852
  sbg:revisionNotes: Docker 2.8.1 and SaveLogs hint
- sbg:revision: 15
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602070052
  sbg:revisionNotes: SaveLogs update
- sbg:revision: 16
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602243190
  sbg:revisionNotes: Description update
- sbg:revision: 17
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602254787
  sbg:revisionNotes: Input and output description updated
- sbg:revision: 18
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603797047
  sbg:revisionNotes: Config cleaning
- sbg:revision: 19
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603798468
  sbg:revisionNotes: Genome build default value update
- sbg:revision: 20
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603904287
  sbg:revisionNotes: Config cleaning
- sbg:revision: 21
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603963103
  sbg:revisionNotes: Config cleaning
- sbg:revision: 22
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1608903445
  sbg:revisionNotes: CWLtool compatible
- sbg:revision: 23
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1608906885
  sbg:revisionNotes: Docker update
sbg:image_url:
sbg:license: MIT
sbg:categories:
- GWAS
- Genesis
- CWL 1.0
sbg:wrapperAuthor: ''
sbg:toolAuthor: TOPMed DCC
sbg:appVersion:
- v1.1
id: https://api.sb.biodatacatalyst.nhlbi.nih.gov/v2/apps/boris_majic/genesis-pipelines-demo/sliding-window-association-testing/23/raw/
sbg:id: boris_majic/genesis-pipelines-demo/sliding-window-association-testing/23
sbg:revision: 23
sbg:revisionNotes: Docker update
sbg:modifiedOn: 1608906885
sbg:modifiedBy: dajana_panovic
sbg:createdOn: 1574269240
sbg:createdBy: boris_majic
sbg:project: boris_majic/genesis-pipelines-demo
sbg:sbgMaintained: false
sbg:validationErrors: []
sbg:contributors:
- dajana_panovic
- boris_majic
sbg:latestRevision: 23
sbg:publisher: sbg
sbg:content_hash: aeacf0d6e7c185883f2584d361631bd5eb83c2f04c57a69fc8e9bdb486e0631fc
