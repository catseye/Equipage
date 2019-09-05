FROM node:8.11.4

USER node

ENV NPM_PACKAGES=/home/node/.npm-packages
ENV PATH="${NPM_PACKAGES}/bin:${PATH}"

RUN mkdir $NPM_PACKAGES \ 
    && echo 'prefix=${NPM_PACKAGES}' >> $HOME/.npmrc \
    && npm install -g bower pulp purescript@0.11.7