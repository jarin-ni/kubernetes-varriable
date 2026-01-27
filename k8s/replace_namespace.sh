sed -i "s|\$(NAMESPACE)|nextcloud|g" **/*.yaml
sed -i "s|\$(PV_NAME)|nextcloud-nfs-pv-var|g" *.yaml
