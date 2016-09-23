FROM kitto

ADD . /dashboard
WORKDIR /dashboard

ENV MIX_ENV prod

RUN mix deps.get
RUN npm install

CMD mix kitto.server
