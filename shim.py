#!/usr/bin/python3

import hy  # NOQA
from app import app

if __name__ == '__main__':
    app.config.from_object('config.DevelopmentConfig')
    app.run()
