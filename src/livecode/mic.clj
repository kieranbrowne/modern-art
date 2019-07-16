(ns livecode.mic
  (:require [overtone.at-at :as at]))

(def amplitude (atom 0))
(def mic-pool (at/mk-pool))



(def audioformat (new javax.sound.sampled.AudioFormat 44100 16 2 true true))
(def info (new javax.sound.sampled.DataLine$Info javax.sound.sampled.TargetDataLine audioformat))
(if (not= (javax.sound.sampled.AudioSystem/isLineSupported info))(print "dataline not supported")(print "ok lets start\n"))
(def line (javax.sound.sampled.AudioSystem/getTargetDataLine audioformat))


(defn abs [x] (if (> x 0) x (- x)))

(defn read-mic []
  (let [size (/ (.getBufferSize line) 15)
        buf (byte-array size)]
    (if (> (.read line buf 0 size) 0)
      (/ (reduce + (map abs buf)) 80000.)
      0)))


(defn start-mic []
  (.open line audioformat)
  (.start line)
  (at/every (/ 1000 60) #(reset! amplitude (read-mic)) mic-pool)
  )

(defn stop-mic []
  (.close line)
  (at/stop-and-reset-pool! mic-pool :strategy :kill)
  )
