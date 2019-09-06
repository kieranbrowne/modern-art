#define S(a,b,x) smoothstep(a,b,x)
#define PI 3.14159265359

float t = iGlobalTime;

mat2 rotate(float theta) {
  return mat2(cos(theta), -sin(theta),sin(theta),cos(theta));
}

mat2 identity = mat2(1.,0.,0.,1.);

// pixel pos
vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy) / iResolution.y * 2.;
// background color
vec3 c = vec3(.99,.9,.8);

//c.yx *= rotate(1.);


mat3 yuv = mat3(1., 0., 1.13983, 1., -.39465, -.5806, 1., 2.03211, 0.);


float noise(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898,126.7378)))
               * 43758.5453) * 2.0-1.0;
}


float ngon(vec2 uv, vec2 pos, int n) {
  uv += pos;
  float a = atan(uv.x,uv.y)+PI;
  float r = PI*2./float(n);
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

float sdBox( in vec2 p, in vec2 b ) {
  vec2 d = abs(p)-b;
  return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
}

float line( in vec2 p, in vec2 a, in vec2 b ) {
  vec2 pa = p-a, ba = b-a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h );
}


void draw(vec3 color, float norm) {
  c = mix(c, color, max(0.,norm));
}

void thing1(vec2 off, float rot) {
  draw(vec3(.99,.9,.8), S(.005,.0,line((uv+off)*rotate(rot), vec2(-0.125*0, -0.125*1), vec2(-.125*1.,-.125*0.))));
}

void thing2(vec2 off, float rot) {
  draw(vec3(.99,.9,.8), S(.005,.0,abs(.125-length(uv+off))));
}

void main () {

  draw(vec3(0.), smoothstep(.92,.91,ngon(uv, vec2(0.),4)));

  vec3 paper = vec3(.99,.9,.8);

  // uv.y += min(fract(uv.x*2.), 1. - fract(uv.x*2.))*.2 - .05;
  // uv.x += min(fract(uv.y*2.), 1. - fract(uv.y*2.))*.2 - .05;
  uv.y += sin(uv.x*10.)*.05;

  // uv *= rotate(sin(min(length(uv),.53))/2);
  // uv *= rotate(PI*.25);

  draw(paper,
       (smoothstep(.995,1.,cos(uv.x*25.+PI))
        +smoothstep(.995,1.,cos(uv.y*25.+PI))
       - smoothstep(.995,1.,cos(uv.x*25.+PI))
        *smoothstep(.995,1.,cos(uv.y*25.+PI)))

       *smoothstep(.634,.63,ngon(uv, vec2(0.),4))

       );


  for(float i =-.125*4; i<= .125*4; i+=.125*2.) {
    for(float j =-.125*4; j<= .125*4.5; j+=.125*2.) {
      // if(mod(i,.2)>.1 )
      // thing1(vec2(i,j), floor(i*j*143)*PI*.5);
      // if(fract(j*93.34092)>.8 ) {
      //   if(fract(i*93.34092)>.2 ) {
        // thing1(vec2(i,j), floor(i*j*15)*PI*.5 +PI);
        thing1(vec2(i,j), floor(i*j*1991.39)*PI*.25 );
        // thing2(vec2(i,j), 0.);
      //   }
      // }
    }
  }


  // draw(paper, S(.005,.0,line(uv, vec2(0.124*3, .124), vec2(0.124,.620))));
  // draw(paper, S(.005,.0,line(uv, vec2(0.124*3, .124), vec2(0.124,-.620 +.122*4))));
  // draw(paper, S(.005,.0,line(uv, vec2(0.124*3, .124-.125*4), vec2(0.124,.620 -.125*4))));


  // draw(paper, S(.005,.0,abs(.250-length(uv+.125)))
  //      *step(-.125,uv.x)
  //      *step(uv.y,.125));

  // draw(paper, S(.005,.0,abs(.250-length(uv+.125 +vec2(0.,-.125*3))))
  //      *step(uv.x,-.125)
  //      *step(-.125,uv.y));

  // draw(paper, S(.005,.0,line(uv, vec2(0.125, 0.125), vec2(0.,.0))));
  // draw(paper, S(.005,.0,line(uv, vec2(0.125*3, -0.125*3), vec2(0.,.0))));
  // draw(paper, S(.005,.0,line(uv, vec2(0.125*3, -0.125*3), vec2(.125*2,-.125*4.))));

  // draw(paper, S(.005,.0,line(uv, vec2(0.125, 0.125*2), vec2(-.125,.125*4.))));
  // draw(paper, S(.005,.0,line(uv, vec2(-0.125*4, 0.125*1), vec2(-.125,.125*4.))));
  // draw(paper, S(.005,.0,line(uv, vec2(-0.125*2, -0.125*4), vec2(.125*3.,.125*1.))));
  // draw(paper, S(.005,.0,line(uv, vec2(-0.125*2, -0.125*4), vec2(-.125*3.,-.125*3.))));
  // draw(paper, S(.005,.0,line(uv, vec2(-0.125*2, -0.125*1), vec2(-.125*3.,-.125*2.))));
  // draw(paper, S(.005,.0,line(uv, vec2(-0.125*2, -0.125*1), vec2(-.125*3.,-.125*0.))));
  // draw(paper, S(.005,.0,line(uv, vec2(0.25, 0.5), vec2(0.,.0))));


  gl_FragColor = vec4(c, 1.);
}
