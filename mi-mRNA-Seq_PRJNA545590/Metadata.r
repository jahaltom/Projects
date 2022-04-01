library(biomaRt)  

#Set up marts
human = useMart("ensembl", dataset = "hsapiens_gene_ensembl")
rat = useMart("ensembl", dataset = "rnorvegicus_gene_ensembl")


#Read in ensembl_transcript_id_version IDs
TranscriptIDs = read.table("TranscriptIDs",header=FALSE)
ID_List=as.vector(unlist(TranscriptIDs['V1']))

#Gather Rat data
df_Rat=getBM(attributes = c("ensembl_transcript_id_version","ensembl_gene_id","gene_biotype","description"), 
                 filters = "ensembl_transcript_id_version", 
                 values = ID_List , 
                 mart = rat)
                 
#Gather RatHuman Ortholog data                 
df_RatHumanOrtho = getLDS(attributes = c("ensembl_transcript_id_version","hsapiens_homolog_orthology_type"), 
                 filters = "ensembl_transcript_id_version", 
                 values = ID_List , 
                 mart = rat, 
                 attributesL = c("hgnc_symbol","ensembl_gene_id","gene_biotype","description"),             
                 martL = human, 
                 uniqueRows=T)
#Rename so that dfs have matching ensembl_transcript_id_version column                   
names(df_RatHumanOrtho)[names(df_RatHumanOrtho) == "Transcript.stable.ID.version"] <- "ensembl_transcript_id_version"               
#Merge dfs by ensembl_transcript_id_version
df_RatHumanOrtho= merge(df_RatHumanOrtho,df_Rat,by="ensembl_transcript_id_version",all=TRUE)


write.table(df_RatHumanOrtho,"RatHumanOrtho.tsv" ,sep = '\t',row.names = FALSE)
