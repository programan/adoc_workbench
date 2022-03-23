FROM asciidoctor/docker-asciidoctor:1.17
MAINTAINER programan <github@programan.com>

COPY ./files/patches/ /patches/

# AsciiDoc内のPlantUMLで日本語を使った場合に豆腐になってしまうので別途fontを入れて対応
RUN set -x \
  && apk update \
  && apk add --no-cache su-exec \
  && mkdir -p /usr/local/share/fonts/truetype \
  && curl -SL https://launchpad.net/takao-fonts/trunk/15.03/+download/TakaoFonts_00303.01.tar.xz \
  |  tar -JxvC /usr/local/share/fonts/truetype

# asciidoctor-pdfコマンドが長いので自作のシェルを登録しておく
RUN set -x \
  && GEM_INSTALLED_PATH=`gem environment | grep -i "\- INSTALLATION DIRECTORY" | tr -d ' ' | awk -F'[:]' '{print $2}'` \
  && ASCII_PDF_INSTALL_DIR=`gem contents asciidoctor-pdf --show-install-dir` \
  && PDF_THEME_DIR="${ASCII_PDF_INSTALL_DIR:-${GEM_INSTALLED_PATH}/gems/asciidoctor-pdf}/data/themes" \
  && echo -e '#! /bin/bash\nset -eu\n' > adocpdf.sh \
  && echo -en "asciidoctor-pdf -r asciidoctor-diagram -r /patches/prawn_japanese_patch.rb -r asciidoctor-mathematical -a mathematical-format=svg -a pdf-stylesdir=${PDF_THEME_DIR} -a pdf-style=default-with-fallback-font-theme.yml -a scripts=cjk" >> adocpdf.sh \
  && echo ' "$@"' >> adocpdf.sh \
  && mv adocpdf.sh /usr/local/bin/ \
  && chmod +x /usr/local/bin/adocpdf.sh

WORKDIR /documents

CMD ["/bin/bash"]
