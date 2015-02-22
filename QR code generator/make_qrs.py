from PyQRNative import *
from PIL import Image, ImageFont, ImageDraw, ImageOps


def get_qr_with_id(id, qr_level, error_level, _font="/Library/Fonts/Courier New Bold.ttf", font_size=30):
    qr = QRCode(qr_level, error_level, 20)
    qr.addData(id)
    qr.make()
    qr_im = qr.makeImage()
    
    result_im = Image.new("1", (qr_im.size[0], qr_im.size[1]+60), "white")
    result_im.paste( qr_im, (0,0) )

    font = ImageFont.truetype(_font, font_size, encoding="unic")
    img_txt = Image.new("L", (qr_im.size[0], font_size), "white")
    draw = ImageDraw.Draw(img_txt)
    draw.text( (0, 0), id,  font=font, fill="black")

    txt_x = int(result_im.size[0]/2.0 - len(id) * font_size / 2.0 +40)
    result_im.paste(img_txt, ( txt_x, qr_im.size[1] -60))

    result_im.save( "qr_images/{id}.bmp".format(id=id, font=_font.split('/')[-1]) )
    return result_im

if __name__ == "__main__":
    
    data = open("YEP_added.csv",'r').read().split('\r')

    for i in range(1, len(data)):
    #for i in range(1, 5):
        get_qr_with_id( data[i].split(',')[0], 4, QRErrorCorrectLevel.H, "/Library/Fonts/Geneva.dfont", 65)
        #get_qr_with_id( data[i].split(',')[2], 4, QRErrorCorrectLevel.H, "/Library/Fonts/GenevaCY.dfont", 65).show()
        print "# %s, %s is printed" % (i, data[i].split(',')[1])

