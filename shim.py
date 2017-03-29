import hy  # NOQA
from app import app

if __name__ == '__main__':
    app.debug = True
    app.secret_key = "kJj5p9tth9Q824VbxJbJsYVrDebJyhEE"
    app.run()
