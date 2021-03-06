#!/bin/bash
#
# Copyright (c) 2009-2014 finfra.com <nowage@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

echo "########################################################################"
echo "########################################################################"
. ~/_setting/doAll.sh
x=`ls -als \`which /usr/bin/java\`|awk '{print $NF}'`
y=`ls -als $x|awk '{print $NF}'`
#/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.55.x86_64
echo ${y/\/bin\/java/}>javaHome

 cd /root/_setting
 #Set Variable
 hostCnt=$(grep -c ".*" ~/_setting/host)

# shutdown firewall.
chkconfig iptables off
service iptables stop
# make script access
chmod 755 /root/
chmod 755 /root/_setting
. hSetup1ByRoot.sh namenode

for i in `seq 2 $hostCnt`;do
	# shutdown firewall.
	sshpass -f ~/.ssh/pass ssh s$i chkconfig iptables off
	sshpass -f ~/.ssh/pass ssh s$i service iptables stop
	# make script access
 	sshpass -f ~/.ssh/pass ssh s$i chmod 755 /root/
 	sshpass -f ~/.ssh/pass ssh s$i chmod 755 /root/_setting
 	sshpass -f ~/.ssh/pass ssh s$i ls /root/hadoop-2.4.0.tar.gz
 	x=`sshpass -f ~/.ssh/pass ssh s$i ls /root/|grep hadoop-2.4.0.tar.gz`
 	if [ ${#x} -eq 0 ];then 
 		echo coping hadoop-2.4.0.tar.gz 
 		sshpass -f ~/.ssh/pass scp /root/hadoop-2.4.0.tar.gz          s$i:/root
 	fi
 	sshpass -f ~/.ssh/pass scp /root/_setting/*    s$i:/root/_setting/
 	sshpass -f ~/.ssh/pass ssh s$i . ~/_setting/hSetup1ByRoot.sh $i
done 




cp -r /root/_setting /home/hadoop/_setting
chown -R  hadoop /home/hadoop/_setting

cat ~/.ssh/pass > /home/hadoop/.ssh/pass
chown hadoop /home/hadoop/.ssh/pass
sshpass -f ~/.ssh/pass ssh hadoop@s1 . /home/hadoop/_setting/doAll.sh


for i in `seq 2 $hostCnt`;do
	sshpass -f ~/.ssh/pass ssh hadoop@s$i  /root/_setting/hSetup3ByHadoop.sh $i
done
sshpass -f ~/.ssh/pass ssh hadoop@s1  /root/_setting/hSetup3ByHadoop.sh  'namenode' 
echo "########################################################################"
echo "########################################################################"
