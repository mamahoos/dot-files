// Smooth caret for Ghostty (custom-shader).
// Approximates VS Code "cursorSmoothCaretAnimation" + "cursorBlinking: smooth".
// Ghostty has no first-class settings for those; this interpolates the
// cursor rect and fades opacity. Pair with cursor-opacity = 0 so the
// native snapped caret is not drawn underneath.

float quintic01(float x)
{
    x = clamp(x, 0.0, 1.0);
    return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
}

// Official layout: xy = -X,+Y corner (top edge), zw = width/height, +Y down.
float insideRect(vec2 p, vec4 r)
{
    vec2 q = p - r.xy;
    vec2 d = abs(q - r.zw * 0.5) - r.zw * 0.5;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec4 screen = texture(iChannel0, uv);
    fragColor = screen;

    if (iCursorVisible < 1) {
        return;
    }

    const float moveSec = 0.08;
    float moveT = quintic01((iTime - iTimeCursorChange) / moveSec);
    vec4 caret = mix(iPreviousCursor, iCurrentCursor, moveT);

    float sdf = insideRect(fragCoord, caret);
    float mask = 1.0 - smoothstep(-0.6, 0.6, sdf);

    const float blinkHz = 1.15;
    float blink = 0.5 + 0.5 * cos(iTime * 6.28318530718 * blinkHz);
    blink = mix(0.12, 1.0, blink);
    blink = mix(1.0, blink, step(0.999, moveT));

    vec4 caretColor = iCurrentCursorColor;
    if (caretColor.a < 0.01) {
        caretColor = vec4(iCursorColor, 1.0);
    }

    fragColor = mix(screen, caretColor, mask * blink * caretColor.a);
}
