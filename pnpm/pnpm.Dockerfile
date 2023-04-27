FROM fj0rd/ng:pnp

RUN set -eux \
  ; pnpm install -g \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
        rescript \
        typescript-language-server typescript \
        vite vite-plugin-solid solid-js \
        @volar/vue-language-server vue \
  ;

#RUN set -eux \
#  ; git clone --depth=1 https://github.com/microsoft/vscode-js-debug.git ${LS_ROOT}/vscode-js-debug \
#  ; cd ${LS_ROOT}/vscode-js-debug \
#  ; pnpm install \
#  ; pnpm run compile \
#  ;

