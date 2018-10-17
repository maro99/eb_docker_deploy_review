from .base import *
import sys
from ..storages import S3DefaultStorage


secrets = json.load(open(os.path.join(SECRET_DIR,'production.json')))

RUNSERVER = sys.argv[1] == 'runserver'
DEBUG = False
ALLOWED_HOSTS = secrets['ALLOWED_HOSTS']
if  RUNSERVER:
    ALLOWED_HOSTS = [
        'localhost',
        '127.0.0.1',
    ]



WSGI_APPLICATION = 'config.wsgi.production.application'
INSTALLED_APPS += [
    'storages',
]

# DB
DATABASES = secrets["DATABASES"]

# Media
DEFAULT_FILE_STORAGE = "config.storages.S3DefaultStorage"
AWS_STORAGE_BUCKET_NAME = secrets["AWS_STORAGE_BUCKET_NAME"]


LOG_DIR = '/var/log/django'
if not os.path.exists(LOG_DIR):
    LOG_DIR = os.path.join(ROOT_DIR, '.log')
    if not os.path.exists(LOG_DIR):
        os.makedirs(LOG_DIR)


LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse',
        },
        'require_debug_true': {
            '()': 'django.utils.log.RequireDebugTrue',
        },
    },
    'formatters': {
        'django.server': {
            'format': '[%(asctime)s] %(message)s',
        }
    },
    'handlers': {
        'console': {
            'level': 'INFO',
            'filters': ['require_debug_true'],
            'class': 'logging.StreamHandler',
        },
        'file_error': {
            'class': 'logging.handlers.RotatingFileHandler',
            'level': 'ERROR',
            'formatter': 'django.server',
            'backupCount': 10,
            'filename': os.path.join(LOG_DIR, 'error.log'),
            'maxBytes': 10485760,
        }
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file_error'],
            'level': 'INFO',
            'propagate': True,
        }
    }
}