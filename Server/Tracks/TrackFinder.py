from flask import Blueprint, jsonify, send_file, send_from_directory
from os import listdir, path, environ

from Chromecast import chromecast

BASE_DIR = environ.get('BASE_DIRECTORY')
BASE_URL = environ.get('BASE_URL')

track_blueprint = Blueprint("Tracks", __name__, url_prefix="/tracks")


@track_blueprint.route('/', methods=['GET'])
def index():
    files = []
    for i in listdir(BASE_DIR):
        tracks = listdir(path.join(BASE_DIR, i))
        if len(tracks) > 0:
            files.append(i)
    return jsonify(files)


@ track_blueprint.route('/<cd>/<int:tid>', methods=['GET'])
def track(cd: str, tid: int):
    if tid < 10:
        tid = "0" + str(tid)
    return send_file(path.join(path.join(BASE_DIR, cd), '{cd}-track{tid}.mp3'.format(cd=cd, tid=tid)))


@track_blueprint.route('/<cd>/thumbnail', methods=['GET'])
def thumbnail(cd: str):
    return send_file(path.join(path.join(BASE_DIR, cd), 'thumbnail.png'))


@ track_blueprint.route('/<cd>/play', methods=['POST'])
def play(cd: str):
    files = listdir(path.join(BASE_DIR, cd))
    tracks = list(filter(lambda x: x.endswith('.mp3'), files))
    for i in range(len(tracks)):
        chromecast.play(
            "{base_url}/tracks/{cd}/{i}".format(cd=cd, i=i+1, base_url=BASE_URL), i > 0, cd)
    return jsonify({'status': 'ok'})
