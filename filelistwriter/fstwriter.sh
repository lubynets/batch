FILES_PER_LIST=1

# # --------------- dcmqgsm_smm 3.3agev ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# OUTPUT_PATH=/lustre/cbm/users/lubynets/filelists/cbm2atree/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56/TGeant4/${FILES_PER_LIST}perfile
# 
# # INPUT_PATH=/lustre/cbm/users/lubynets/cbm2atree/outputs/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56/AT2
# # # FROM=1
# # # TO=250
# # # FROM=501
# # # TO=750
# # # FROM=1501
# # # TO=1750
# # # FROM=2001
# # # TO=2250
# # FROM=2501
# # TO=2750
# 
# # INPUT_PATH=/lustre/cbm/users/iselyuzh/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56/TGeant4/atree
# # FROM=251
# # TO=500
# # FROM=751
# # TO=1000
# # FROM=1251
# # TO=1500
# # FROM=1751
# # TO=2000
# 
# # INPUT_PATH=/lustre/cbm/users/iselyuzh/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_etap/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56/TGeant4/atree
# # FROM=1001
# # TO=1250
# 
# INPUT_PATH=/lustre/cbm/users/iselyuzh/mc/cbmsim/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_inmed_had_epem/auau/3.3agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56/TGeant4/atree
# FROM=2751
# TO=3000
# #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# # # --------------- dcmqgsm_smm 12agev ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# OUTPUT_PATH=/lustre/cbm/users/lubynets/filelists/cbm2atree/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm/${FILES_PER_LIST}perfile
# 
# INPUT_PATH=/lustre/cbm/users/lubynets/cbm2atree/outputs/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm/AT2
# FROM=1
# TO=5000
# # #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# # --------------- urqmd 12agev --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
OUTPUT_PATH=/lustre/cbm/users/lubynets/filelists/cbm2atree/apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm/${FILES_PER_LIST}perfile

INPUT_PATH=/lustre/cbm/users/lubynets/cbm2atree/outputs/apr20_fr_18.2.1_fs_jun19p1/urqmd_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm/AT2
FROM=1001
TO=3000
# #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





mkdir -p $OUTPUT_PATH

for INDEX in `seq $FROM $TO`
do
I=$(($(($(($INDEX-1))/$FILES_PER_LIST))+1))
echo $INDEX $I
ls -d $INPUT_PATH/$INDEX/$INDEX.analysistree.root >> $OUTPUT_PATH/filelist.$I.list
# ls -d $INPUT_PATH/$INDEX.analysistree.root >> $OUTPUT_PATH/filelist.$I.list
done