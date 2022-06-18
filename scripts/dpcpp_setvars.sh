echo " .. Installing DPCPP with NVidia support .."
export PATH=$PATH:/usr/local/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

cp -r /dpcpp_cuda/deploy/bin/* /usr/local/bin/
cp -r /dpcpp_cuda/deploy/lib/* /usr/local/lib/
cp -r /dpcpp_cuda/deploy/include/* /usr/local/include/
echo "Done!"

