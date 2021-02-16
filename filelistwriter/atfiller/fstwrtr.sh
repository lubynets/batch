ATREE_PATH=/lustre/cbm/users/lubynets/cbm2atree/outputs/apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm

N=100
M=50

for I in `seq 1 $N`
do
echo $I
for J in `seq 1 $M`
do

INDEX=$(($(($(($I-1))*$M))+$J))

ls -d $ATREE_PATH/$INDEX/$INDEX.analysistree.root >> filelist.$I.txt

done
done