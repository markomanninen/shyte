#!/usr/bin/python3

import hy  # NOQA
from app import app
import flask_babel as babel
from flask import g, request

if __name__ == '__main__':

    app.config.from_object('config.DevelopmentConfig')
    
    b = babel.Babel(app)

    @b.localeselector
    def get_locale():
        # if a user is logged in, use the locale from the user settings
        user = getattr(g, 'user', None)
        if user is not None:
            return user.locale
        # otherwise try to guess the language from the user accept
        # header the browser transmits.  We support de/fr/en in this
        # example.  The best match wins.
        return request.accept_languages.best_match(['fi', 'en'])

    @b.timezoneselector
    def get_timezone():
        user = getattr(g, 'user', None)
        if user is not None:
            return user.timezone

    app.run()
