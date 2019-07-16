(ns livecode.core
  (:require [shadertone.shader :as shader]))


(shader/start
 "./live.glsl"
 :width 900 :height 500
 :display-sync-hz 2
 )

(shader/stop)
