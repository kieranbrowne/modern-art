(ns livecode.core
  (:require [shadertone.shader :as shader]))


(shader/start
 "./live.glsl"
 :width 680 :height 680
 :display-sync-hz 19)

(shader/stop)

