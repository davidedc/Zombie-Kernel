class PencilIconAppearance extends IconAppearance

  paintFunction: (context) ->
    fillColor = @morph.color

    context.save()
    context.translate 90.18, 101.32
    context.rotate 13.16 * Math.PI / 180
    context.beginPath()
    context.moveTo 23.88, -86.27
    context.lineTo 74.38, -51.12
    context.lineTo 88.21, -73.65
    context.lineTo 86.24, -90.9
    context.lineTo 54.61, -112.65
    context.lineTo 37.52, -108.5
    context.lineTo 23.88, -86.27
    context.closePath()
    context.moveTo 16.57, -74.36
    context.lineTo 67.23, -39.53
    context.lineTo -16.17, 96.43
    context.lineTo -62.07, 112.55
    context.lineTo -66.83, 61.61
    context.lineTo 16.57, -74.36
    context.closePath()
    context.fillStyle = fillColor.toString()
    context.fill()
    context.restore()
