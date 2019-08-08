(ns livecode.core
  (:require [shadertone.shader :as shader]))


(shader/start
 "./live.glsl"
 :width 980 :height 980
 :display-sync-hz 60
 )

(shader/stop)
