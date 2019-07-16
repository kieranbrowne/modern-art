(ns livecode.core
  (:require [shadertone.shader :as shader]))


(shader/start
 "./live.glsl"
 :width 700 :height 700
 :display-sync-hz 60
 )

(shader/stop)
