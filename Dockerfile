FROM asciidoctor/docker-asciidoctor:1.39

MAINTAINER programan <github@programan.com>

COPY ./files/patches/ /patches/
COPY ./files/pdf-theme/ /pdf-theme/

# AsciiDoc内のPlantUMLで日本語を使った場合に豆腐になってしまうので別途fontを入れて対応
RUN set -x \
  && apk update \
  && apk add --no-cache su-exec \
  && apk add --no-cache fontconfig \
  && mkdir -p /usr/local/share/fonts/truetype \
  && curl -SL https://launchpad.net/takao-fonts/trunk/15.03/+download/TakaoFonts_00303.01.tar.xz | \
    tar -JxvC /usr/local/share/fonts/truetype \
  && cd /tmp \
  && curl -SL https://github.com/yuru7/HackGen/releases/download/v2.8.0/HackGen_NF_v2.8.0.zip -o HackGen_NF.zip \
  && curl -SL https://fonts.google.com/download?family=M%20PLUS%201 -o M_PLUS_1p.zip \
  && unzip -d /usr/local/share/fonts/truetype/ HackGen_NF.zip \
  && unzip -d /usr/local/share/fonts/truetype/M_PLUS_1p/ M_PLUS_1p.zip \
  && fc-cache -f -v \
  && rm /tmp/*.zip

# asciidoctor-pdfコマンドが長いので自作のシェルを登録しておく
RUN set -x \
  && GEM_INSTALLED_PATH=`gem environment | grep -i "\- INSTALLATION DIRECTORY" | tr -d ' ' | awk -F'[:]' '{print $2}'` \
  && ASCII_PDF_INSTALL_DIR=`gem contents asciidoctor-pdf --show-install-dir` \
  && PDF_THEME_DIR="${ASCII_PDF_INSTALL_DIR:-${GEM_INSTALLED_PATH}/gems/asciidoctor-pdf}/data/themes" \
  && echo -e '#! /bin/bash\nset -eu\n' > adocpdf.sh \
  && echo -en "asciidoctor-pdf -r asciidoctor-diagram -r /patches/prawn_japanese_patch.rb -r asciidoctor-mathematical -a mathematical-format=svg -a pdf-themesdir=${PDF_THEME_DIR} -a pdf-theme=my-theme.yml -a scripts=cjk" >> adocpdf.sh \
  && echo ' "$@"' >> adocpdf.sh \
  && mv adocpdf.sh /usr/local/bin/ \
  && chmod +x /usr/local/bin/adocpdf.sh \
  && cp /pdf-theme/*.yml ${PDF_THEME_DIR}

WORKDIR /documents

CMD ["/bin/bash"]
