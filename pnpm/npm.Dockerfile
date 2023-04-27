FROM fj0rd/ng:pnp

RUN set -eux \
  ; npm install --location=global \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
        rescript \
        typescript-language-server typescript \
        vite vite-plugin-solid solid-js \
        @volar/vue-language-server vue \
  ; npm cache clean -f \
  ;

#RUN set -eux \
#  ; git clone --depth=1 https://github.com/microsoft/vscode-js-debug.git ${LS_ROOT}/vscode-js-debug \
#  ; cd ${LS_ROOT}/vscode-js-debug \
#  ; npm install \
#  ; NODE_OPTIONS=--no-experimental-fetch npm run compile \
#  ; npm cache clean -f

