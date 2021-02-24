class: CommandLineTool
cwlVersion: v1.1
$namespaces:
  sbg: https://sevenbridges.com
id: boris_majic/genesis-toolkit-demo/assoc_window/12
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
- sbg:toolDefaultValue: assoc_window
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
  label: Test
  doc: Test to perform. Options are burden, skat, smmat, fastskat, or skato. Default
    test is burden.
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
  doc: Segment Number.
- sbg:toolDefaultValue: 'True'
  id: pass_only
  type: boolean?
  label: Pass only
  doc: TRUE to select only variants with FILTER=PASS.
- sbg:toolDefaultValue: 50kb
  id: window_size
  type: int?
  label: Window size
  doc: 'Size of sliding window in kb. Default: 50kb.'
- sbg:toolDefaultValue: 20kb
  id: window_step
  type: int?
  label: Window step
  doc: 'Step size of sliding window in kb. Default: 20kb.'
- id: variant_weight_file
  type: File?
  label: Variant weight file
  doc: Variant weight file.
- sbg:toolDefaultValue: '1'
  id: alt_freq_max
  type: float?
  label: Alt freq max
  doc: 'Maximum alternate allele frequency to consider. Default: 1.'
- sbg:toolDefaultValue: weight
  id: weight_user
  type: string?
  label: Weight user
  doc: Name of column in variant_weight_file or variant_group_file containing the
    weight for each variant.
- sbg:toolDefaultValue: '8'
  id: memory_gb
  type: float?
  label: memory GB
  doc: 'Memory in GB per job. Default value: 8GB.'
- sbg:category: Input options
  sbg:toolDefaultValue: '1'
  id: cpu
  type: int?
  label: CPU
  doc: 'Number of CPUs for each tool job. Default value: 1.'
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
  default: hg38
outputs:
- id: assoc_window
  doc: Assoc Window Output.
  label: Assoc Window Output
  type: File?
  outputBinding:
    glob: '*.RData'
    outputEval: $(inheritMetadata(self, inputs.gds_file))
  sbg:fileTypes: RDATA
- id: config_file
  label: Config file
  type: File?
  outputBinding:
    glob: '*.config'
  sbg:fileTypes: CONFIG
label: assoc_window
arguments:
- prefix: ''
  shellQuote: false
  position: 1
  valueFrom: |-
    ${
        var cmd_line = "Rscript /usr/local/analysis_pipeline/R/assoc_window.R assoc_window.config ";

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
    ${
        if(inputs.cpu)
            return parseInt(inputs.cpu)
        else
            return 1
    }
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.8.1
- class: InitialWorkDirRequirement
  listing:
  - entryname: assoc_window.config
    entry: |-
      ${
          var config = "";

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
          if (inputs.out_prefix)
              config += "out_prefix \"" + inputs.out_prefix+ '_chr'+ chr +"\"\n"
          else
          {
              var data_prefix = inputs.gds_file.basename.split('chr');
              var data_prefix2 = inputs.gds_file.basename.split('.chr');
              if(data_prefix.length == data_prefix2.length)
                  config += "out_prefix \"" + data_prefix2[0] + "_window_chr" + chr +"\"\n"
              else
                  config += "out_prefix \"" + data_prefix[0] + "window_chr" + chr +"\"\n"
          }
          config += "gds_file \"" + inputs.gds_file.path + "\"\n"
          
          config += "phenotype_file \"" + inputs.phenotype_file.path + "\"\n"
          config += "null_model_file \"" + inputs.null_model_file.path + "\"\n"

          if(inputs.rho)
          {
              config += "rho \"";
              for(var i=0; i<inputs.rho.length; i++)
              {
                  config += inputs.rho[i].toString() + " ";
              }
              config += "\"\n";
          }
          if(inputs.segment_file)
              config += "segment_file \"" + inputs.segment_file.path + "\"\n"
          if(inputs.test)
             config += "test " + inputs.test + "\n"
          if(inputs.test_type)
              config += "test_type \"" + inputs.test_type + "\"\n"
          if(inputs.variant_include_file)
              config +="variant_include_file \"" + inputs.variant_include_file.path + "\"\n"
          if(inputs.weight_beta)
              config +="weight_beta \"" + inputs.weight_beta + "\"\n"
          if(inputs.window_size)
              config +="window_size \""  + inputs.window_size + "\"\n"
          if(inputs.window_step)
              config +="window_step \"" + inputs.window_step + "\"\n"
              
          if(inputs.alt_freq_max)
              config +="alt_freq_max \"" + inputs.alt_freq_max + "\"\n"
          if(!inputs.pass_only)
              config += "pass_only FALSE"+ "\n"
          if(inputs.variant_weight_file)
              config +="variant_weight_file \"" + inputs.variant_weight_file.path + "\"\n"
          if(inputs.weight_user)
              config +="weight_user \"" + inputs.weight_user + "\"\n"  
          if(inputs.genome_build)
              config +="genome_build \"" + inputs.genome_build + "\"\n"      
          
          return config
      }
    writable: false
- class: InlineJavascriptRequirement
  expressionLib:
  - |2-

    var setMetadata = function(file, metadata) {
        if (!('metadata' in file))
            file['metadata'] = metadata;
        else {
            for (var key in metadata) {
                file['metadata'][key] = metadata[key];
            }
        }
        return file
    };

    var inheritMetadata = function(o1, o2) {
        var commonMetadata = {};
        if (!Array.isArray(o2)) {
            o2 = [o2]
        }
        for (var i = 0; i < o2.length; i++) {
            var example = o2[i]['metadata'];
            for (var key in example) {
                if (i == 0)
                    commonMetadata[key] = example[key];
                else {
                    if (!(commonMetadata[key] == example[key])) {
                        delete commonMetadata[key]
                    }
                }
            }
        }
        if (!Array.isArray(o1)) {
            o1 = setMetadata(o1, commonMetadata)
        } else {
            for (var i = 0; i < o1.length; i++) {
                o1[i] = setMetadata(o1[i], commonMetadata)
            }
        }
        return o1;
    };
hints:
- class: sbg:SaveLogs
  value: job.out.log
sbg:revisionsInfo:
- sbg:revision: 0
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1570638126
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/0
- sbg:revision: 1
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1572536420
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/1
- sbg:revision: 2
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1573666789
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/3
- sbg:revision: 3
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584013894
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/4
- sbg:revision: 4
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584014715
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/5
- sbg:revision: 5
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593600077
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/6
- sbg:revision: 6
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593621251
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/7
- sbg:revision: 7
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1594658136
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/8
- sbg:revision: 8
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1594721828
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/9
- sbg:revision: 9
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602060511
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/10
- sbg:revision: 10
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602065189
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/11
- sbg:revision: 11
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603725673
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/12
- sbg:revision: 12
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1608736390
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/13
sbg:projectName: GENESIS toolkit - DEMO
sbg:image_url:
sbg:appVersion:
- v1.1
sbg:id: boris_majic/genesis-toolkit-demo/assoc_window/12
sbg:revision: 12
sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/assoc_window/13
sbg:modifiedOn: 1608736390
sbg:modifiedBy: dajana_panovic
sbg:createdOn: 1570638126
sbg:createdBy: boris_majic
sbg:project: boris_majic/genesis-toolkit-demo
sbg:sbgMaintained: false
sbg:validationErrors: []
sbg:contributors:
- dajana_panovic
- boris_majic
sbg:latestRevision: 12
sbg:publisher: sbg
sbg:content_hash: a1534fcd516db66e6181a6d3d57b9ecc967820005844a1e21c1f18ab15009b38d
sbg:copyOf: boris_majic/genesis-toolkit-dev/assoc_window/13
