(ns livecode.core
  (:require [shadertone.shader :as shader]))


(shader/start
 "./live.glsl"
 :width 900 :height 900
 :display-sync-hz 3
 )

(shader/stop)
