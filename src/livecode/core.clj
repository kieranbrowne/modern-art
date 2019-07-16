(ns livecode.core
  (:require [shadertone.shader :as shader]))


(shader/start
 "./live.glsl"
 :width 1080 :height 1080
 :display-sync-hz 1
 )

(shader/stop)
