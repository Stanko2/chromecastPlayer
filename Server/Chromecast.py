import os
import pychromecast
import time
import os
import threading


class Chromecast():
    def __init__(self):
        self.connect()
        self.queue = []
        self.thread = threading.Thread(target=self.updateQueue)
        self.thread.setDaemon(True)
        self.thread.start()
        pass

    def updateQueue(self):
        while True:
            if self.getStatus()["state"] != "PLAYING":
                time.sleep(3)
                continue
            if len(self.queue) > 0:
                self.mc.play_media(
                    self.queue[0]["url"], 'video/mp4', title=self.queue[0]["title"])
                self.mc.play()
                self.queue.pop(0)
            time.sleep(3)

    def connect(self):
        try:
            print(os.environ.get('CHROMECAST_NAME'))
            chromecasts, browser = pychromecast.get_listed_chromecasts(friendly_names=[
                os.environ.get('CHROMECAST_NAME')])
            self.cast = chromecasts[0]
            self.cast.wait()
            self.mc = self.cast.media_controller
        except IndexError:
            time.sleep(5)
            print("error connecting to Chromecast, retry")
            self.connect()

    def play(self, url="", enqueue=False, title=None):
        if enqueue:
            self.queue.append({"url": url, "title": title})
            return
        self.queue.clear()
        if url != "":
            self.mc.play_media(url, 'video/mp4', title=title)
        self.mc.play()

    def pause(self):
        self.mc.pause()

    def getStatus(self):
        self.mc.update_status()
        status = self.mc.status
        return {
            "track": status.title,
            "time": status.current_time,
            "duration": status.duration,
            "volume": status.volume_level,
            "state": status.player_state
        }

    def volumeUp(self):
        self.cast.volume_up()

    def volumeDown(self):
        self.cast.volume_down()

    def seek(self, position):
        self.mc.seek(position)

    def stop(self):
        self.mc.stop()


def main():
    chromecasts, browser = pychromecast.get_listed_chromecasts(friendly_names=[
                                                               "Living Room"])
    print(chromecasts)
    cast = chromecasts[0]
    cast.wait()
    mc = cast.media_controller
    mc.play_media(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'audio/mp3')
    mc.block_until_active()
    print(mc.status)
    mc.play()
    time.sleep(10)
    mc.pause()


chromecast = Chromecast()


if __name__ == '__main__':
    main()
