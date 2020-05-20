FROM asciidoctor/docker-asciidoctor:1.1.0
MAINTAINER programan <github@programan.com>

# AsciiDoc内のPlantUMLで日本語を使った場合に豆腐になってしまうので対応
RUN set -x \
  && mkdir -p /usr/share/fonts/opentype \
  && curl -SL https://launchpad.net/takao-fonts/trunk/15.03/+download/TakaoFonts_00303.01.tar.xz \
  |  tar -JxvC /usr/share/fonts/opentype

# asciidoctor-pdfコマンドが長いので自作のシェルを登録しておく
RUN set -x \
  && GEM_INSTALLED_PATH=`gem environment | grep -i "\- INSTALLATION DIRECTORY" | tr -d ' ' | awk -F'[:]' '{print $2}'` \
  && ASCII_PDF_INSTALL_DIR=`gem contents asciidoctor-pdf --show-install-dir` \
  && PDF_THEME_DIR="${ASCII_PDF_INSTALL_DIR:-${GEM_INSTALLED_PATH}/gems/asciidoctor-pdf}/data/themes" \
  && echo -e '#! /bin/bash\nset -eu\n' > adocpdf.sh \
  && echo -en "asciidoctor-pdf -r asciidoctor-diagram -r asciidoctor-mathematical -a pdf-stylesdir=${PDF_THEME_DIR} -a pdf-style=default-with-fallback-font-theme.yml -a scripts=cjk" >> adocpdf.sh \
  && echo ' "$@"' >> adocpdf.sh \
  && mv adocpdf.sh /usr/local/bin/ \
  && chmod +x /usr/local/bin/adocpdf.sh
