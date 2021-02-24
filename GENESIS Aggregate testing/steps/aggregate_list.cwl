class: CommandLineTool
cwlVersion: v1.1
$namespaces:
  sbg: https://sevenbridges.com
id: boris_majic/genesis-toolkit-demo/aggregate-list/11
baseCommand: []
inputs:
- sbg:category: Input File
  id: variant_group_file
  type: File
  label: Variant group file
  doc: RData file with data frame defining aggregate groups. If aggregate_type is
    allele, columns should be group_id, chromosome, position, ref, alt. If aggregate_type
    is position, columns should be group_id, chromosome, start, end.
  sbg:fileTypes: RDATA
- sbg:toolDefaultValue: allele
  sbg:category: Input Options
  id: aggregate_type
  type:
  - 'null'
  - type: enum
    symbols:
    - position
    - allele
    name: aggregate_type
  label: Aggregate type
  doc: Type of aggregate grouping. Options are to select variants by allele (unique
    variants) or position (regions of interest). Default is allele.
- sbg:toolDefaultValue: aggregate_list.RData
  id: out_file
  type: string?
  label: Out file
  doc: Out file.
- sbg:category: General
  sbg:toolDefaultValue: group_id
  id: group_id
  type: string?
  label: Group ID
  doc: Alternate name for group_id column.
outputs:
- id: aggregate_list
  label: Aggregate list
  type: File?
  outputBinding:
    glob: |-
      ${
          var comm;
          
          if (!inputs.variant_group_file.basename.includes('chr'))
          {
              return '*RData'
          }
        if (!inputs.out_file) {
          comm = "aggregate_list*.RData"
        } else {
          	comm = inputs.out_file + ".RData"
        }
        return comm
      }
  sbg:fileTypes: RDATA
- id: config_file
  label: Config file
  type: File?
  outputBinding:
    glob: '*.config'
  sbg:fileTypes: CONFIG
label: aggregate_list
arguments:
- prefix: ''
  shellQuote: false
  position: 0
  valueFrom: |-
    ${  
        var cmd_line;
        if (inputs.variant_group_file)
        {
            cmd_line = "cp " + inputs.variant_group_file.path + " " + inputs.variant_group_file.basename
        
            return cmd_line
        }
        else
        {
            return "echo variant group file not provided"
        }
    }
- prefix: ''
  shellQuote: false
  position: 0
  valueFrom: |-
    ${
        var cmd_line = "";
        if (inputs.variant_group_file)
        {
            cmd_line = "&& Rscript /usr/local/analysis_pipeline/R/aggregate_list.R aggregate_list.config "
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
        
        function isNumeric(s) {
            return !isNaN(s - parseFloat(s));
        }
        
        var chromosome;
        
        if (inputs.variant_group_file.basename.includes('chr'))
        {
    	    chromosome = find_chromosome(inputs.variant_group_file.path)
            cmd_line += "--chromosome " + chromosome 
            return cmd_line
        }
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
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.8.1
- class: InitialWorkDirRequirement
  listing:
  - entryname: aggregate_list.config
    entry: |-
      ${
          function find_chromosome(file){
              var chr_array = [];
              var chrom_num = file.split("/").pop();
              chrom_num = file.split("chr")[1]
              
              if(isNumeric(chrom_num.charAt(1)))
              {
                  chr_array.push(chrom_num.substr(0,2))
              }
              else
              {
                  chr_array.push(chrom_num.substr(0,1))
              }
              return chr_array.toString();
          }
          
          function isNumeric(s) {
              return !isNaN(s - parseFloat(s));
          }
          
          var argument = [];
          
          
          if (inputs.variant_group_file.basename.includes('chr'))
          {   
              var chr = find_chromosome(inputs.variant_group_file.path);
              var chromosomes_basename = inputs.variant_group_file.path.slice(0,-6).replace(/\/.+\//g,"");
               
              var i; 
              for(i = chromosomes_basename.length - 1; i > 0; i--)
                  if(chromosomes_basename[i] != 'X' && chromosomes_basename[i] != "Y" && isNaN(chromosomes_basename[i]))
                      break;
              chromosomes_basename = inputs.variant_group_file.basename.split('chr'+chr)[0]+"chr "+ inputs.variant_group_file.basename.split('chr'+chr)[1]
              
              argument.push('variant_group_file "' + chromosomes_basename + '"')
          }
          else
          {
              argument.push('variant_group_file "' + inputs.variant_group_file.basename + '"')
          }
          
          if(inputs.out_file)
              if (inputs.variant_group_file.basename.includes('chr')){
                  
                  argument.push('out_file "' + inputs.out_file + ' .RData"')}
              else
                  argument.push('out_file "' + inputs.out_file + '.RData"')
          else
          {
              if (inputs.variant_group_file.basename.includes('chr'))
                  argument.push('out_file "aggregate_list_chr .RData"')
              else
                  argument.push('out_file aggregate_list.RData')
          }
              

          if(inputs.aggregate_type)
              argument.push('aggregate_type "' + inputs.aggregate_type + '"')
          
          if(inputs.group_id)
              argument.push('group_id "' + inputs.group_id + '"')
          
          return argument.join('\n') + '\n'

      }
    writable: false
- class: InlineJavascriptRequirement
hints:
- class: sbg:SaveLogs
  value: job.out.log
sbg:projectName: GENESIS toolkit - DEMO
sbg:image_url:
sbg:revisionsInfo:
- sbg:revision: 0
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1570638144
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/aggregate-list/0
- sbg:revision: 1
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1573666778
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/aggregate-list/1
- sbg:revision: 2
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1574267882
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/aggregate-list/4
- sbg:revision: 3
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1583426575
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/aggregate-list/5
- sbg:revision: 4
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1583952445
  sbg:revisionNotes: find_chromosome updated
- sbg:revision: 5
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1584006432
  sbg:revisionNotes: Comand line --chromosome updated
- sbg:revision: 6
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1591618975
  sbg:revisionNotes: Variant group filename updated
- sbg:revision: 7
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593600153
  sbg:revisionNotes: 'New docker image: 2.8.0'
- sbg:revision: 8
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593621946
  sbg:revisionNotes: Inputs description updated.
- sbg:revision: 9
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602060804
  sbg:revisionNotes: Docker 2.8.1 and SaveLogs hint
- sbg:revision: 10
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602065115
  sbg:revisionNotes: SaveLogs hint
- sbg:revision: 11
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1608826312
  sbg:revisionNotes: CWLtool prep
sbg:appVersion:
- v1.1
sbg:id: boris_majic/genesis-toolkit-demo/aggregate-list/11
sbg:revision: 11
sbg:revisionNotes: CWLtool prep
sbg:modifiedOn: 1608826312
sbg:modifiedBy: dajana_panovic
sbg:createdOn: 1570638144
sbg:createdBy: boris_majic
sbg:project: boris_majic/genesis-toolkit-demo
sbg:sbgMaintained: false
sbg:validationErrors: []
sbg:contributors:
- dajana_panovic
- boris_majic
sbg:latestRevision: 11
sbg:publisher: sbg
sbg:content_hash: ac07aeeb403224371db07ea50ae81405284bab5f3dd9677605c10f1a3d41f88b3
