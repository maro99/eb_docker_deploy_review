FROM                python:3.6.5-slim
MAINTAINER          nadcdc4@gmail.com



RUN                 apt -y update && apt -y dist-upgrade

RUN                 apt -y install build-essential
# nginx, supervisor install (uwsgi는 Pipfile에 기록)
RUN                 apt -y install nginx supervisor

# 로컬의 requriements.txt. 파일을 /srv 에 복사한 후 pip install 실행
# (build 하는 환경에 requirements.txt 가 있어야 함.)
COPY                ./requirements.txt /srv/
RUN                 pip install -r /srv/requirements.txt




# 이하 production에서 복사.


ENV             PROJECT_DIR     /srv/project
ENV                 BUILD_MODE              production

#nginx ,supervisor install
ENV                 DJANGO_SETTINGS_MODULE  config.settings.${BUILD_MODE}


# Copy projects files
COPY            .   ${PROJECT_DIR}
#WORKDIR         ${PROJECT_DIR}



# Nginx 설정파일들 복사 및 enabled로 링크
RUN             cp -f   /srv/project/.config/${BUILD_MODE}/nginx.conf \
                        /etc/nginx/nginx.conf && \

            # available에 nginx_app.conf파일 복사
                cp -f   /srv/project/.config/${BUILD_MODE}/nginx_app.conf \
                        /etc/nginx/sites-available/ && \

            # 이미 sites-enabled에 있던 모든 내용 삭제
#                rm -f   /etc/nginx/sites-enabled/* && \

            # available에 있는 nginx_app.conf를 enabled로 링크.
                ln -sf  /etc/nginx/sites-available/nginx_app.conf \
                        /etc/nginx/sites-enabled/


# Supervisor 설정복사
RUN             cp -f ${PROJECT_DIR}/.config/${BUILD_MODE}/supervisor.conf \
                        /etc/supervisor/conf.d

# 7000번 포트 open
EXPOSE          7000


# RUN supervisor
CMD             supervisord -n