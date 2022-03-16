from flask import Blueprint, jsonify, request
from itsdangerous import json
from Chromecast import chromecast

player_blueprint = Blueprint("Player", __name__, url_prefix="/player")


@player_blueprint.route('/')
def index():
    return 'hello world'


@player_blueprint.route('/play', methods=['POST'])
def play():
    req = json.loads(request.data)
    if 'url' in req:
        chromecast.play(req['url'])
    else:
        chromecast.play()
    return jsonify({'status': 'ok'})


@player_blueprint.route('/pause', methods=['POST'])
def pause():
    chromecast.pause()
    return jsonify({'status': 'ok'})


@player_blueprint.route('/status', methods=['GET'])
def status():
    try:
        return jsonify(chromecast.getStatus())
    except AttributeError:
        return jsonify({'state': 'UNKNOWN'})


@player_blueprint.route('/volume/up', methods=['POST'])
def volumeUp():
    chromecast.volumeUp()
    return jsonify({'status': 'ok'})


@player_blueprint.route('/volume/down', methods=['POST'])
def volumeDown():
    chromecast.volumeDown()
    return jsonify({'status': 'ok'})


@player_blueprint.route('/seek', methods=['POST'])
def seek():
    req = json.loads(request.data)
    if 'position' not in req:
        return jsonify({'status': 'err'}), 400
    chromecast.seek(req['position'])
    return jsonify({'status': 'ok'})


@player_blueprint.route('/stop', methods=['POST'])
def stop():
    chromecast.stop()
    return jsonify({'status': 'ok'})
