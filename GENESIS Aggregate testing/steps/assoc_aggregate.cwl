class: CommandLineTool
cwlVersion: v1.1
$namespaces:
  sbg: https://sevenbridges.com
id: boris_majic/genesis-toolkit-demo/assoc_aggregate/13
baseCommand: []
inputs:
- sbg:category: Input File
  id: gds_file
  type: File
  label: GDS file
  doc: GDS File.
  sbg:fileTypes: GDS
- sbg:category: Input File
  id: null_model_file
  type: File
  label: Null model file
  doc: Null model file.
  sbg:fileTypes: RDATA
- sbg:category: Input File
  id: phenotype_file
  type: File
  label: Phenotype file
  doc: RData file with AnnotatedDataFrame of phenotypes. Used for plotting kinship
    estimates separately by study.
  sbg:fileTypes: RDATA
- id: aggregate_variant_file
  type: File
  label: Aggregate variant file
  doc: File with regions that we want to test.
  sbg:fileTypes: RDATA
- sbg:toolDefaultValue: assoc_aggregate
  sbg:category: Inputs
  id: out_prefix
  type: string?
  label: Output prefix
  doc: Output prefix.
- sbg:toolDefaultValue: '0'
  id: rho
  type: float[]?
  label: Rho
  doc: A numeric value or list of values in range [0,1] specifying the rho parameter
    when test is skat. 0 is a standard SKAT test, 1 is a score burden test, and multiple
    values is a SKAT-O test.
- sbg:category: Input files
  id: segment_file
  type: File?
  label: Segment File
  doc: Segment File.
  sbg:fileTypes: TXT
- sbg:toolDefaultValue: burden
  id: test
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
  label: Test type
  doc: Test to perform. Options are burden, skat, smmat, fastskat, or skato.
- id: variant_include_file
  type: File?
  label: Variant Include File
  doc: Variants to be included when perform testing.
  sbg:fileTypes: RDATA
- sbg:toolDefaultValue: 1 1
  id: weight_beta
  type: string?
  label: Weight Beta
  doc: Parameters of the Beta distribution used to determine variant weights, two
    space delimited values. "1 1" is flat weights, "0.5 0.5" is proportional to the
    Madsen-Browning weights, and "1 25" gives the Wu weights. This parameter is ignored
    if weight_user is provided.
- sbg:category: Input Options
  id: segment
  type: int?
  inputBinding:
    prefix: --segment
    shellQuote: false
    position: 10
  label: Segment number
  doc: Segment Number
- sbg:toolDefaultValue: Allele
  id: aggregate_type
  type:
  - 'null'
  - type: enum
    symbols:
    - allele
    - position
    name: aggregate_type
  label: Aggregate type
  doc: Type of aggregate grouping. Options are to select variants by allele (unique
    variants) or position (regions of interest).
- sbg:toolDefaultValue: '1'
  id: alt_freq_max
  type: float?
  label: Alt Freq Max
  doc: Maximum alternate allele frequency to consider.
- sbg:toolDefaultValue: 'TRUE'
  id: pass_only
  type: boolean?
  label: Pass only
  doc: TRUE to select only variants with FILTER=PASS.
- id: variant_weight_file
  type: File?
  label: Variant Weight file
  doc: Variant Weight file.
- id: weight_user
  type: string?
  label: Weight user
  doc: Name of column in variant_weight_file or variant_group_file containing the
    weight for each variant.
- sbg:category: Input options
  sbg:toolDefaultValue: '1'
  id: cpu
  type: int?
  label: CPU
  doc: 'Number of CPUs for each tool job. Default value: 1.'
- sbg:category: Input options
  sbg:toolDefaultValue: '8'
  id: memory_gb
  type: float?
  label: memory GB
  doc: 'Memory in GB per job. Default value: 8.'
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
outputs:
- id: assoc_aggregate
  label: Assoc aggregate output
  type: File?
  outputBinding:
    glob: |-
      ${
          /*
        if (!inputs.out_prefix) {
          comm = "assoc_aggregate*.RData"
        } else {
          	comm = inputs.out_prefix + ".RData"
        }
        return comm */
        return "*.RData"
      }
  sbg:fileTypes: RDATA
- id: config
  label: Config file
  type: File?
  outputBinding:
    glob: '*.config'
  sbg:fileTypes: CONFIG
label: assoc_aggregate
arguments:
- prefix: ''
  shellQuote: false
  position: 1
  valueFrom: |-
    ${
        var cmd_line = "Rscript /usr/local/analysis_pipeline/R/assoc_aggregate.R assoc_aggregate.config ";

        function isNumeric(s) {

            return !isNaN(s - parseFloat(s));
        }

        function find_chromosome(file){

            var chr_array = [];
            var chrom_num = file.split("/").pop();
            chrom_num = chrom_num.split(".")[0]
            
            if(isNumeric(chrom_num.charAt(chrom_num.length-2)))
            {
                chr_array.push(chrom_num.substr(chrom_num.length - 2))
            }
            else
            {
                chr_array.push(chrom_num.substr(chrom_num.length - 1))
            }

            return chr_array.toString()
        }
        
    // 	chromosome = find_chromosome(inputs.gds_file.path)
    //     cmd_line += "--chromosome " + chromosome 
        return cmd_line
        
    }
- prefix: ''
  shellQuote: false
  position: 0
  valueFrom: |-
    ${
        if (inputs.cpu)
            return 'export NSLOTS=' + inputs.cpu + ' &&'
        else
            return ''
    }
- prefix: ''
  shellQuote: false
  position: 100
  valueFrom: |-
    ${
        return ' >> job.out.log'
    }
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  ramMin: |-
    ${
        if(inputs.memory_gb)
            return parseFloat(inputs.memory_gb * 1024)
        else
            return 8*1024
    }
  coresMin: |-
    ${ if(inputs.cpu)
            return inputs.cpu 
        else 
            return 1
    }
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.8.1
- class: InitialWorkDirRequirement
  listing:
  - entryname: assoc_aggregate.config
    entry: |-
      ${
              function isNumeric(s) {
              return !isNaN(s - parseFloat(s));
          }
          function find_chromosome(file){
              var chr_array = [];
              var chrom_num = file.split("chr")[1];
              
              if(isNumeric(chrom_num.charAt(1)))
              {
                  chr_array.push(chrom_num.substr(0,2))
              }
              else
              {
                  chr_array.push(chrom_num.substr(0,1))
              }
              return chr_array.toString()
          }
              
          
          var chr = find_chromosome(inputs.gds_file.path);
          
          var config = "";
          
          if(inputs.out_prefix)
              config += "out_prefix \"" + inputs.out_prefix + "_chr"+chr + "\"\n"
          else
          {
              var data_prefix = inputs.gds_file.basename.split('chr');
              var data_prefix2 = inputs.gds_file.basename.split('.chr');
              
              if (data_prefix.length == data_prefix2.length)
                  config += 'out_prefix "' + data_prefix2[0] + '_aggregate_chr' + chr + inputs.gds_file.basename.split('chr'+chr)[1].split('.gds')[0] +'"'+ "\n";
              else
                  config += 'out_prefix "' + data_prefix[0] + 'aggregate_chr' + chr +inputs.gds_file.basename.split('chr'+chr)[1].split('.gds')[0]+'"' + "\n";
          } 
          if(inputs.gds_file)
              config += "gds_file \"" + inputs.gds_file.path + "\"\n"
          if(inputs.phenotype_file)
              config += "phenotype_file \"" + inputs.phenotype_file.path + "\"\n"
          if(inputs.aggregate_variant_file)
              config += "aggregate_variant_file \"" + inputs.aggregate_variant_file.path + "\"\n"
          if(inputs.null_model_file)
              config += "null_model_file \"" + inputs.null_model_file.path + "\"\n"
          if(inputs.null_model_params)
              config += "null_model_params \"" + inputs.null_model_params.path + "\"\n"
          if(inputs.rho)
          {
              config += "rho \"";;
              for(var i=0; i<inputs.rho.length; i++)
              {
                  config += inputs.rho[i].toString() + " ";
              }
              config += "\"\n";
          }
          if(inputs.segment_file)
              config += "segment_file \"" + inputs.segment_file.path + "\"\n"
          if(inputs.test)
             config += "test \"" + inputs.test + "\"\n"
          if(inputs.test_type)
              config += "test_type \"" + inputs.test_type + "\"\n"
          if(inputs.variant_include_file)
              config +="variant_include_file \"" + inputs.variant_include_file.path + "\"\n"
          if(inputs.weight_beta)
              config +="weight_beta \"" + inputs.weight_beta + "\"\n"
          if(inputs.aggregate_type)
              config +="aggregate_type \"" + inputs.aggregate_type + "\"\n"
          if(inputs.alt_freq_max)
              config +="alt_freq_max " + inputs.alt_freq_max + "\n"
          if(!inputs.pass_only)
              config += "pass_only FALSE"+ "\n"
          if(inputs.variant_weight_file)
              config +="variant_weight_file \"" + inputs.variant_weight_file + "\"\n"
          if(inputs.weight_user)
              config +="weight_user \"" + inputs.weight_user + "\"\n"
          if(inputs.genome_build)
              config +="genome_build \"" + inputs.genome_build + "\"\n"    
              
          return config
      }
    writable: false
- class: InlineJavascriptRequirement
hints:
- class: sbg:SaveLogs
  value: job.out.log
sbg:revisionsInfo:
- sbg:revision: 0
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1570638141
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/0
- sbg:revision: 1
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1572520967
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/1
- sbg:revision: 2
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1573666781
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/2
- sbg:revision: 3
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1583774265
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/3
- sbg:revision: 4
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1583775650
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_aggregate/4
- sbg:revision: 5
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1583847218
  sbg:revisionNotes: Output prefix corrected
- sbg:revision: 6
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1583873542
  sbg:revisionNotes: ''
- sbg:revision: 7
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593600204
  sbg:revisionNotes: 'New docker image: 2.8.0'
- sbg:revision: 8
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593621893
  sbg:revisionNotes: Inputs description updated
- sbg:revision: 9
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1594657928
  sbg:revisionNotes: parseFloat
- sbg:revision: 10
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602060759
  sbg:revisionNotes: Docker 2.8.1 and SaveLogs hint
- sbg:revision: 11
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602065154
  sbg:revisionNotes: SaveLogs hint
- sbg:revision: 12
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603726598
  sbg:revisionNotes: Config cleaning
- sbg:revision: 13
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1608826571
  sbg:revisionNotes: CWLtool prep
sbg:projectName: GENESIS toolkit - DEMO
sbg:image_url:
sbg:appVersion:
- v1.1
sbg:id: boris_majic/genesis-toolkit-demo/assoc_aggregate/13
sbg:revision: 13
sbg:revisionNotes: CWLtool prep
sbg:modifiedOn: 1608826571
sbg:modifiedBy: dajana_panovic
sbg:createdOn: 1570638141
sbg:createdBy: boris_majic
sbg:project: boris_majic/genesis-toolkit-demo
sbg:sbgMaintained: false
sbg:validationErrors: []
sbg:contributors:
- dajana_panovic
- boris_majic
sbg:latestRevision: 13
sbg:publisher: sbg
sbg:content_hash: ae557365f1c5d59d6f5852a42b53aa3ac55f0856629fc83129aff7845a5f3fe42
