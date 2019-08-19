#define S(a,b,x) smoothstep(a,b,x)
#define PI 3.14159265359
mat2 rotate(float theta) {
  return mat2(cos(theta), -sin(theta),sin(theta),cos(theta));
}

// pixel pos
vec2 uv;
// background color
vec3 c = vec3(235.,231.,222.)/259;

//c.yx *= rotate(1.);


mat3 yuv = mat3(1., 0., 1.13983, 1., -.39465, -.5806, 1., 2.03211, 0.);


float noise(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898,126.7378)))
               * 43758.5453) * 2.0-1.0;
}


float ngon(vec2 uv, vec2 pos, int n) {
  uv += pos;
  float a = atan(uv.x,uv.y)+3.145;
  float r = 6.28/float(n);
  return cos(floor(.5+a/r)*r-a)*length(uv);
}

float circle(vec2 pos) {
  return length(uv+pos);
}


vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 *
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

























float smin( float a, float b, float k )
{
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

// float smin( float a, float b, float k )
// {
//   a = pow( a, k ); b = pow( b, k );
//   return pow( (a*b)/(a+b), 1.0/k );
// }

float sdBox( in vec2 p, in vec2 b )
{
  vec2 d = abs(p)-b;
  return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
}
float sdArc( in vec2 p, in vec2 sca, in vec2 scb, in float ra, float rb )
{
  p *= mat2(sca.x,sca.y,-sca.y,sca.x);
  p.x = abs(p.x);
  float k = (scb.y*p.x>scb.x*p.y) ? dot(p.xy,scb) : length(p.xy);
  return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}
float line( in vec2 p, in vec2 a, in vec2 b )
{
  vec2 pa = p-a, ba = b-a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h );
}
float triangle( in vec2 p, in vec2 p0, in vec2 p1, in vec2 p2 )
{
  vec2 e0 = p1-p0, e1 = p2-p1, e2 = p0-p2;
  vec2 v0 = p -p0, v1 = p -p1, v2 = p -p2;
  vec2 pq0 = v0 - e0*clamp( dot(v0,e0)/dot(e0,e0), 0.0, 1.0 );
  vec2 pq1 = v1 - e1*clamp( dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
  vec2 pq2 = v2 - e2*clamp( dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
  float s = sign( e0.x*e2.y - e0.y*e2.x );
  vec2 d = min(min(vec2(dot(pq0,pq0), s*(v0.x*e0.y-v0.y*e0.x)),
                   vec2(dot(pq1,pq1), s*(v1.x*e1.y-v1.y*e1.x))),
               vec2(dot(pq2,pq2), s*(v2.x*e2.y-v2.y*e2.x)));
  return -sqrt(d.x)*sign(d.y);
}

float stripedtriangle(vec2 p, vec2 p0, vec2 p1, vec2 p2) {
  return S(.003,.00, triangle(p,p0, p1, p2))
    *S(.1,1., sin(uv.x*640. +1.9))
    +S(.003,.00, abs(triangle(p,p0, p1, p2)));
}


void draw(vec3 color, float norm) {
  c = mix(c, color, max(0.,norm));
}


float hexDist(vec2 uv) {
  return
       max(dot(abs(uv), normalize(vec2(1.,sqrt(3)))),
           abs(uv).x);
}


vec4 hexCoords(vec2 uv) {
  vec2 rep = vec2(1.,sqrt(3.));
  vec2 h = rep*.5;
  vec2 a = mod(uv*5, rep) -h;
  vec2 b = mod(uv*5-h, rep) -h;
  vec2 gv;
  if(length(a) < length(b))
    gv = a;
  else gv = b;

  vec2 id = uv*5-gv;

  return vec4(gv.x,gv.y,id.x,id.y);
}


void coolline(vec3 col, vec2 uv, vec2 a, vec2 b, float outline) {
  float warp = 0.;
  // warp += cnoise(uv)*.02;
  warp += cnoise(uv*3)*.02;
  warp += cnoise(uv*2)*.02;
  warp += cnoise(uv*5)*.02;
  // warp += cnoise(uv*9)*.01;
  warp += cnoise(uv*29)*.004;
  warp += cnoise(uv*49)*.001;
  warp += cnoise(uv*149)*.0008;
  warp += cnoise(uv*189)*.0003;

  draw(vec3(.01, 0.05, 0.04),
       S(outline+.03,outline,line(uv+warp +cnoise(uv*100)/120., a, b)));
  draw(col,
       S(.004,.0,line(uv+warp, a, b)));
}
void coolarc(vec3 col, vec2 uv, vec2 sca, vec2 scb, float ra, float rb, float outline) {
  float warp = 0.;
  // warp += cnoise(uv)*.02;
  warp += cnoise(uv*3)*.02;
  warp += cnoise(uv*2)*.02;
  warp += cnoise(uv*5)*.02;
  // warp += cnoise(uv*9)*.01;
  warp += cnoise(uv*29)*.004;
  warp += cnoise(uv*49)*.001;
  warp += cnoise(uv*149)*.0008;
  warp += cnoise(uv*189)*.0003;

  draw(vec3(.01, 0.05, 0.04),
       S(outline+.03,outline,
         sdArc(uv+warp +cnoise(uv*100)/120., sca, scb, ra, rb)));
  draw(col,
       S(.004,.0,sdArc(uv+warp, sca, scb, ra,rb)));
}


void main () {
  uv = (gl_FragCoord.xy-.5*iResolution.xy) / iResolution.y * 2.;


  draw(normalize(vec3(.2,.26,.9)), 1.);

  draw(vec3(.7,.25,.96), S(.15,.00,abs(.5- length(uv))));
  draw(vec3(0.9,.16,.49), S(.05,.00,abs(.5- length(uv)))*.8);
  draw(vec3(0.8,.16,.29), S(.02,.00,abs(.5- length(uv)))*.8);

  gl_FragColor = vec4(c, 1.);
}
