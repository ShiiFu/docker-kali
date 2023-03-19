FROM kalilinux/kali-rolling

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get upgrade -y

### Core tools ###

# To install all the applications that are included in official Kali Linux images and that don’t require X11/GUI.
RUN apt-get install -y kali-linux-headless
# More with apt search kali-linux- and apt search kali-tools-

# Find tools at https://www.kali.org/tools

### Basic tools ###

RUN apt-get install -y man
RUN apt-get install -y inetutils-ping
RUN apt-get install -y golang
RUN apt-get install -y python2 python2.7-dev libpython2-dev

# pip for python2
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
RUN python2 get-pip.py
RUN rm get-pip.py
RUN pip2 install setuptools wheel

# pip for python3
RUN apt-get install -y python3-pip

# Redis tools for redis-cli
RUN apt-get install -y redis-tools

# tldr
RUN apt-get install -y tldr
#RUN tldr -u
# cheat.sh
RUN curl -s https://cht.sh/:cht.sh | tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh

### Security tools ###

# Osint tools
## SMAP
RUN go install -v github.com/s0md3v/smap/cmd/smap@latest
RUN echo "export PATH=$PATH:/root/go/bin" >> /root/.zshrc
## Holehe
RUN git clone --depth 1 https://github.com/megadose/holehe.git /opt/holehe
WORKDIR /opt/holehe
#RUN python3 setup.py install

# SSH tool
## SSH-Audit
RUN pip3 install ssh-audit

# Web tools
## dirsearch
RUN apt-get install -y dirsearch
## flask-unsign (JWT)
RUN pip3 install flask-unsign
## testssl
RUN git clone --depth 1 https://github.com/drwetter/testssl.sh /opt/testssl
RUN ln -s /opt/testssl/testssl.sh /usr/local/bin/testssl
## Nuclei
RUN git clone --depth 1 https://github.com/projectdiscovery/nuclei.git /opt/nuclei
WORKDIR /opt/nuclei/v2/cmd/nuclei
RUN go build
RUN mv nuclei /usr/local/bin/

# Active Directory tools
## Kerbrute
RUN git clone --depth 1 --branch v1.0.3 https://github.com/ropnop/kerbrute.git /opt/kerbrute
WORKDIR /opt/kerbrute
RUN sed -i "s/amd64 386/$(dpkg --print-architecture)/g" Makefile
RUN make linux
RUN ln -s /opt/kerbrute/dist/kerbrute_linux_$(dpkg --print-architecture) /usr/local/bin/kerbrute
## Bloodhound collector
RUN pip3 install bloodhound

# Pwncat
RUN pip3 install pwncat-cs

# Volatility 2
RUN git clone --depth 1 https://github.com/volatilityfoundation/volatility /opt/volatility2
RUN sed -i '1s/.*/\#\!\/usr\/bin\/env python2/' /opt/volatility2/vol.py
RUN chmod u+x /opt/volatility2/vol.py
RUN ln -s /opt/volatility2/vol.py /usr/local/bin/volatility2
RUN pip2 install pycryptodome
# Bitlocker plugin
RUN git clone --depth 1 https://github.com/elceef/bitlocker /opt/vol2-bitlocker
RUN ln -s /opt/vol2-bitlocker/bitlocker.py /opt/volatility2/volatility/plugins/bitlocker.py

# Firefox decrypt
RUN git clone --depth 1 https://github.com/unode/firefox_decrypt /opt/firefox_decrypt

# Volatility 3
RUN git clone --depth 1 https://github.com/volatilityfoundation/volatility3.git /opt/volatility3
RUN pip3 install -r /opt/volatility3/requirements-minimal.txt
RUN ln -s /opt/volatility3/vol.py /usr/local/bin/volatility

# fdisk
RUN apt-get install -y fdisk

# EWF tools
RUN apt-get install -y ewf-tools

# Reverse engineering tools
RUN apt-get install -y gdb
# ltrace not available on arm64, ignore error if package not found
RUN apt-get install -y ltrace; exit 0

## Stegano tools
# exiftool
RUN apt-get install -y libimage-exiftool-perl
# steghide
RUN apt-get install -y steghide
# stegseek
RUN git clone --depth 1 https://github.com/RickdeJager/stegseek.git /opt/stegseek
RUN apt-get install -y libmhash-dev libmcrypt-dev libjpeg-dev zlib1g-dev make g++ cmake
RUN mkdir /opt/stegseek/build
WORKDIR /opt/stegseek/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make
RUN make install

# Wordlist
RUN apt-get install -y wordlists
RUN gunzip /usr/share/wordlists/rockyou.txt.gz
RUN git clone --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/seclists
RUN git clone --depth 1 https://github.com/carlospolop/Auto_Wordlists.git /usr/share/wordlists/auto_wordlists

# Haiti - Identify hash
RUN gem install haiti-hash

# Hashcat custom rule
RUN curl https://raw.githubusercontent.com/NotSoSecure/password_cracking_rules/master/OneRuleToRuleThemAll.rule -o /usr/share/hashcat/rules/OneRuleToRuleThemAll.rule
# John the Ripper KoreLogic rules
#RUN curl https://openwall.info/wiki/_media/john/korelogic-rules-20100801.txt -o /usr/share/john/rules/korelogic-rules.rule
#RUN cat /usr/share/john/rules/korelogic-rules.rule >> /etc/john/john.conf

# Android tools
RUN mkdir /opt/apktool
RUN curl https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool --output /opt/apktool/apktool
RUN curl -L https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.6.1.jar --output /opt/apktool/apktool.jar
RUN chmod u+x /opt/apktool/apktool
RUN chmod u+x /opt/apktool/apktool.jar
RUN ln -s /opt/apktool/apktool /usr/local/bin/apktool
RUN ln -s /opt/apktool/apktool.jar /usr/local/bin/apktool.jar

# Cloud tools
## gcloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-cli -y

### Miscellaneous ###

# Custom terminal
RUN apt-get install -y zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Setup locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
RUN echo 'export LANG=en_US.utf8' >> /root/.zshrc

WORKDIR /work

ENTRYPOINT ["sleep", "infinity"]
#CMD ["sleep infinity"]
