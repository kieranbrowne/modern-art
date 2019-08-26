(ns livecode.core
  (:require [shadertone.shader :as shader]))


(shader/start
 "./live.glsl"
 :width 1280 :height 720
 :display-sync-hz 60
 )

(shader/stop)

