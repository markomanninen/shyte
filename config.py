#!/usr/bin/python3
# -*- coding: utf-8 -*-

class Config(object):
    DEBUG = False
    TESTING = False
    SECRET_KEY = "kJj5p9tth9Q824VbxJbJsYVrDebJyhEE"
    DATABASE_URI = 'sqlite://:memory:'
    BABEL_DEFAULT_LOCALE = 'en'

class ProductionConfig(Config):
    DATABASE_URI = 'mysql://user@localhost/foo'

class DevelopmentConfig(Config):
    DEBUG = True

class TestingConfig(Config):
    TESTING = True
