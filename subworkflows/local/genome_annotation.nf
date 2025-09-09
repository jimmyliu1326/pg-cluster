include { MOBSUITE_RECON         } from '../../modules/nf-core/mobsuite/recon/main'
include { CCTYPER                } from '../../modules/local/cctyper/main'
include { VIRSORTER2_RUN         } from '../../modules/local/virsorter2/run/main.nf'
include { VIRSORTER2_SETUP       } from '../../modules/local/virsorter2/setup/main.nf'
include { MOBSUITE_GFF_CONVERSION} from '../../modules/local/gff/mob_convert/main.nf'
include { VIRSORTER2_GFF_CONVERSION} from '../../modules/local/gff/vir_convert/main.nf'

workflow GENOME_ANNOTATION {

    take:
    genome

    main:

    // Initializing empty channels for the output files
    ch_versions = Channel.empty()
    cctyper_gff = Channel.empty()
    virsorter2_gff = Channel.empty()
    mobsuite_gff = Channel.empty()
    
    //CCTYPER
    CCTYPER(genome)
    cctyper_gff = CCTYPER.out.gff
    ch_versions = ch_versions.mix(CCTYPER.out.versions)

    //VIRSORTER2
    VIRSORTER2_RUN(genome)
    ch_versions = ch_versions.mix(VIRSORTER2_RUN.out.versions)
    VIRSORTER2_GFF_CONVERSION(VIRSORTER2_RUN.out.boundary)
    virsorter2_gff = VIRSORTER2_GFF_CONVERSION.out.gff
    
    //MOBSUITE
    MOBSUITE_RECON(genome)
    ch_versions = ch_versions.mix(MOBSUITE_RECON.out.versions)
    MOBSUITE_GFF_CONVERSION(MOBSUITE_RECON.out.plasmids)
    mobsuite_gff = MOBSUITE_GFF_CONVERSION.out.gff
    
    emit:
        cctyper_gff     = cctyper_gff
        virsorter2_gff  = virsorter2_gff
        mobsuite_gff    = mobsuite_gff
        versions        = ch_versions
}