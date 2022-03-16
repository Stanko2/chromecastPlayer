from flask import Flask
from Player.Player import player_blueprint
from Tracks.TrackFinder import track_blueprint
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

app.register_blueprint(player_blueprint)
app.register_blueprint(track_blueprint)
