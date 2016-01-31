//
//  ViewController.swift
//  Encrypton
//
//  Created by Jesus Ruiz on 11/21/15.
//  Copyright © 2015 AkibaTeaParty. All rights reserved.
//
import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {

    @IBOutlet weak var decryptedText: UITextView!
    @IBOutlet weak var texttoEncrypt: UITextView!
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var encriptedImage: UIImageView!

    
    let key:     [[Int]]    = [[3,1],[5,2]]//Matriz llave
    let deKey:   [[Int]]    = [[2,-1],[-5,3]]//Matriz Inversa de llave
    var A:       [[Int]]    = [[]]//Matrices
    var B:       [[Int]]    = [[]]//Resultado
    var toImage: [Int]      = []
    var temp:    [Int]      = []
    var imagePicker         = UIImagePickerController()
    var select:   Int       = 1//Selector para la imagen si 1 entonces original si 2 entonces encriptada
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.texttoEncrypt.delegate = self
        texttoEncrypt.textColor = UIColor.lightGrayColor()
        originalImage.contentMode = UIViewContentMode.ScaleAspectFit
        encriptedImage.contentMode = UIViewContentMode.ScaleAspectFit

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    //Mensaje de error
    func alerte(){
        let alert = UIAlertController(title: "Error", message: "Es necesario un mensaje y una imagen para poder encriptar", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func alertd(){
        let alert = UIAlertController(title: "Error", message: "Es necesario una imagen para poder desencriptar", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    //Edicion de imagen: grabar contenido de palabra en rgb de la imagen
    func processPix(inputImage: UIImage) -> UIImage {
        let inputCGImage     = inputImage.CGImage
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = CGImageGetWidth(inputCGImage)
        let height           = CGImageGetHeight(inputCGImage)
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = CGImageAlphaInfo.PremultipliedLast.rawValue
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)!
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), inputCGImage)
        let pixelBuffer = UnsafeMutablePointer<UInt32>(CGBitmapContextGetData(context))
        var currentPixel = pixelBuffer
        var countA:Int = 0
        var countB:Int = 1
        var countC:Int = 2
        for var i = 0; i < Int(height); i++ {
            for var j = 0; j < Int(width); j++ {
                let pixel = currentPixel.memory
                
                if toImage[countA] == Int(toImage.last!) || toImage[countB] == Int(toImage.last!) || toImage[countC] == Int(toImage.last!) {
                    if toImage[countA] == Int(toImage.last!) || toImage[countB] == Int(toImage.last!){
                        if toImage[countA] == Int(toImage.last!){
                            currentPixel.memory = rgba(red: 255, green: 0, blue: 0, alpha: alpha(pixel))
                            break
                        }else
                            if toImage[countB] == Int(toImage.last!){
                                currentPixel.memory = rgba(red: UInt8(toImage[countA]), green: 255, blue: 0, alpha: alpha(pixel))
                        }
                        break
                    }else
                        if toImage[countC] == Int(toImage.last!){
                            currentPixel.memory = rgba(red: UInt8(toImage[countA]), green: UInt8(toImage[countB]), blue: 255, alpha: alpha(pixel))
                    }
                    break
                }
                if i <= Int(height) && j <= Int(width){
                    currentPixel.memory = rgba(red: UInt8(toImage[countA]), green: UInt8(toImage[countB]), blue: UInt8(toImage[countC]), alpha: alpha(pixel))
                }
                countA+=3
                countB+=3
                countC+=3
                currentPixel++
            }
        }
        let outputCGImage = CGBitmapContextCreateImage(context)
        let outputImage = UIImage(CGImage: outputCGImage!, scale: inputImage.scale, orientation: inputImage.imageOrientation)
        return outputImage
    }
    
    func red(color: UInt32) -> UInt8 {
        return UInt8(color & 255)
    }
    
    func green(color: UInt32) -> UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    func blue(color: UInt32) -> UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    func alpha(color: UInt32) -> UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    func rgba(red red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) -> UInt32 {
        return UInt32(red) | (UInt32(green) << 8) | (UInt32(blue) << 16) | (UInt32(alpha) << 24)
    }
    //Edicion de imagen: agarrar los datos del rgb y los pasa a un array
    func lectordeImagen(inputImage: UIImage) -> UIImage {
        let inputCGImage     = inputImage.CGImage
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = CGImageGetWidth(inputCGImage)
        let height           = CGImageGetHeight(inputCGImage)
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = CGImageAlphaInfo.PremultipliedLast.rawValue
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)!
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), inputCGImage)
        let pixelBuffer = UnsafeMutablePointer<UInt32>(CGBitmapContextGetData(context))
        var currentPixel = pixelBuffer
        for var i = 0; i < Int(height); i++ {
            for var j = 0; j < Int(width); j++ {
                let pixel = currentPixel.memory
                if i <= Int(height) && j <= Int(width) {
                    temp.append(Int(red(pixel)))
                    temp.append(Int(green(pixel)))
                    temp.append(Int(blue(pixel)))
                }
                currentPixel++
            }
        }
        let outputCGImage = CGBitmapContextCreateImage(context)
        let outputImage = UIImage(CGImage: outputCGImage!, scale: inputImage.scale, orientation: inputImage.imageOrientation)
        return outputImage
    }
    //Para poder seleccionar la imagen
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        if select == 1{
            originalImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        } else{
            encriptedImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
    }
    //Teclado
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            texttoEncrypt.resignFirstResponder()
            return false
        }
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        texttoEncrypt.resignFirstResponder()
    }
    //Acciones de boton
    @IBAction func Add(sender: UIBarButtonItem){
        select = 1
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    //Borrar todo
    @IBAction func ClearAll(sender: UIBarButtonItem){
        texttoEncrypt.text = "*Escribe el mensaje aqui*"
        texttoEncrypt.textColor = UIColor.lightGrayColor()
        decryptedText.text = "Mensaje desencriptado"
        encriptedImage.image = nil
        originalImage.image = nil
    }
    //Añadir imagen encriptada a la aplicacion
    @IBAction func AddEncrypted(sender: UIBarButtonItem){
        select = 2
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    //Guardar imagen encriptada
    @IBAction func Save(sender: UIButton){
        let imageData = UIImagePNGRepresentation(correctlyOrientedImage(encriptedImage.image!))
        let image = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
    }
    //Modificar la orientacion de la imagen proporcionada
    func correctlyOrientedImage(image: UIImage) -> UIImage {
        if image.imageOrientation == UIImageOrientation.Up {
            return image
        }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    //Acciones de encriptar
    func encryption(){
        
        var transform: [Int] = []
        var mov: Int = 0
        for character in (texttoEncrypt.text?.characters)!{//Leer el texto escrito y acomodarlo en array
            switch(character){
            case "a": transform += [1]
            case "b": transform += [2]
            case "c": transform += [3]
            case "d": transform += [4]
            case "e": transform += [5]
            case "f": transform += [6]
            case "g": transform += [7]
            case "h": transform += [8]
            case "i": transform += [9]
            case "j": transform += [10]
            case "k": transform += [11]
            case "l": transform += [12]
            case "m": transform += [13]
            case "n": transform += [14]
            case "o": transform += [15]
            case "p": transform += [16]
            case "q": transform += [17]
            case "r": transform += [18]
            case "s": transform += [19]
            case "t": transform += [20]
            case "u": transform += [21]
            case "v": transform += [22]
            case "w": transform += [23]
            case "x": transform += [24]
            case "y": transform += [25]
            case "z": transform += [26]
            case " ": transform += [0]
            case "A": transform += [27]
            case "B": transform += [28]
            case "C": transform += [29]
            case "D": transform += [30]
            case "E": transform += [31]
            case "F": transform += [32]
            case "G": transform += [33]
            case "H": transform += [34]
            case "I": transform += [35]
            case "J": transform += [36]
            case "K": transform += [37]
            case "L": transform += [38]
            case "M": transform += [39]
            case "N": transform += [40]
            case "O": transform += [41]
            case "P": transform += [42]
            case "Q": transform += [43]
            case "R": transform += [44]
            case "S": transform += [45]
            case "T": transform += [46]
            case "U": transform += [47]
            case "V": transform += [48]
            case "W": transform += [49]
            case "X": transform += [50]
            case "Y": transform += [51]
            case "Z": transform += [52]
            case "ñ": transform += [53]
            case "Ñ": transform += [54]
            case "?": transform += [55]
            case "!": transform += [56]
            default: transform += [0]
            }
        }
        if((transform.count % 2) != 0){//Numero de letras y/o espacios es impar +1 para que se pueda hacer las operaciones
            transform += [0]
        }
        var countsArray: Int = transform.count/2
        A.removeAll()// Limpiar el Array Multidimensional
        B.removeAll()
        toImage.removeAll()
        for _ in transform{
            if(countsArray == 0){//Para que se detenga y no recorra mas de lo que aguanta el index
                break
            }
            A.append(Array(transform[mov..<mov+2]))
            mov += 2
            --countsArray
        }
        var x:Int = 0
        var y:Int = 0
        var x1:Int = 0
        var y1:Int = 0
        for numbers in A{
            for keys in key{
                if(keys == key[0]){
                    x = keys[0] * numbers[0]
                    y = keys[1] * numbers[0]
                }else{
                    y1 = keys[1] * numbers[1]
                    x1 = keys[0] * numbers[1]
                }
            }
            toImage.append(x+x1)
            toImage.append(y+y1)
        }
        toImage.append(8121993)
        texttoEncrypt.text = "*Escribe el mensaje aqui*"
        texttoEncrypt.textColor = UIColor.lightGrayColor()
        let imageData = UIImagePNGRepresentation(correctlyOrientedImage(originalImage.image!))
        let image = UIImage(data: imageData!)
        encriptedImage.image = processPix(image!)
        
    }
    
    @IBAction func Encrypt(sender: UIButton){
        let ima: UIImage? = originalImage.image
        if (texttoEncrypt.text == "*Escribe el mensaje aqui*"){
            self.alerte()
        }else if(ima == nil){
            self.alerte()
        }else {
            self.encryption()
        }
        
    }
    //Accion de desencriptar
    func decryption(){
        var x:Int = 0
        var y:Int = 0
        var x1:Int = 0
        var y1:Int = 0
        var decrypted: String = ""
        var newA: [Int] = []
        var mov: Int = 0
        newA.removeAll()
        temp.removeAll()
        B.removeAll()
        let imageData = UIImagePNGRepresentation(correctlyOrientedImage(encriptedImage.image!))
        let image = UIImage(data: imageData!)
        lectordeImagen(image!)
        if((temp.count % 2) != 0){//Numero de letras y/o espacios es impar +1 para que se pueda hacer las operaciones
            temp += [0]
        }
        var countsArray: Int = temp.count/2
        for _ in temp{
            if( temp[mov] == 255){
                break
            }
            if(countsArray == 0){//Para que se detenga y no recorra mas de lo que aguanta el index
                break
            }
            B.append(Array(temp[mov..<mov+2]))
            mov += 2
            --countsArray
        }
        for numbers in B{//Convertir las matrices al resultado luego pasar los numeros individualmente al array A
            for keys in deKey{
                if(keys == deKey[0]){
                    x = keys[0] * numbers[0]
                    y = keys[1] * numbers[0]
                }else{
                    y1 = keys[1] * numbers[1]
                    x1 = keys[0] * numbers[1]
                }
            }
            newA.append(x+x1)
            newA.append(y+y1)
        }
        for character in newA{//Transformar numeros a letras
            switch(character){
            case 0: decrypted.appendContentsOf(" ")
            case 1: decrypted.appendContentsOf("a")
            case 2: decrypted.appendContentsOf("b")
            case 3: decrypted.appendContentsOf("c")
            case 4: decrypted.appendContentsOf("d")
            case 5: decrypted.appendContentsOf("e")
            case 6: decrypted.appendContentsOf("f")
            case 7: decrypted.appendContentsOf("g")
            case 8: decrypted.appendContentsOf("h")
            case 9: decrypted.appendContentsOf("i")
            case 10: decrypted.appendContentsOf("j")
            case 11: decrypted.appendContentsOf("k")
            case 12: decrypted.appendContentsOf("l")
            case 13: decrypted.appendContentsOf("m")
            case 14: decrypted.appendContentsOf("n")
            case 15: decrypted.appendContentsOf("o")
            case 16: decrypted.appendContentsOf("p")
            case 17: decrypted.appendContentsOf("q")
            case 18: decrypted.appendContentsOf("r")
            case 19: decrypted.appendContentsOf("s")
            case 20: decrypted.appendContentsOf("t")
            case 21: decrypted.appendContentsOf("u")
            case 22: decrypted.appendContentsOf("v")
            case 23: decrypted.appendContentsOf("w")
            case 24: decrypted.appendContentsOf("x")
            case 25: decrypted.appendContentsOf("y")
            case 26: decrypted.appendContentsOf("z")
            case 27: decrypted.appendContentsOf("A")
            case 28: decrypted.appendContentsOf("B")
            case 29: decrypted.appendContentsOf("C")
            case 30: decrypted.appendContentsOf("D")
            case 31: decrypted.appendContentsOf("E")
            case 32: decrypted.appendContentsOf("F")
            case 33: decrypted.appendContentsOf("G")
            case 34: decrypted.appendContentsOf("H")
            case 35: decrypted.appendContentsOf("I")
            case 36: decrypted.appendContentsOf("J")
            case 37: decrypted.appendContentsOf("K")
            case 38: decrypted.appendContentsOf("L")
            case 39: decrypted.appendContentsOf("M")
            case 40: decrypted.appendContentsOf("N")
            case 41: decrypted.appendContentsOf("O")
            case 42: decrypted.appendContentsOf("P")
            case 43: decrypted.appendContentsOf("Q")
            case 44: decrypted.appendContentsOf("R")
            case 45: decrypted.appendContentsOf("S")
            case 46: decrypted.appendContentsOf("T")
            case 47: decrypted.appendContentsOf("U")
            case 48: decrypted.appendContentsOf("V")
            case 49: decrypted.appendContentsOf("W")
            case 50: decrypted.appendContentsOf("X")
            case 51: decrypted.appendContentsOf("Y")
            case 52: decrypted.appendContentsOf("Z")
            case 53: decrypted.appendContentsOf("ñ")
            case 54: decrypted.appendContentsOf("Ñ")
            case 55: decrypted.appendContentsOf("?")
            case 56: decrypted.appendContentsOf("!")
            default: decrypted.appendContentsOf("≈")
            }
            if (decrypted.containsString("≈")){
                break
            }
        }
        let delimiter = "≈"//Delimitador para poder cortar las letras o palabras que saca del array y poner solo el mensaje
        var token = decrypted.componentsSeparatedByString(delimiter)
        decryptedText.text = token[0]

    }
    @IBAction func Decrypt(sender: UIButton){
        let ima: UIImage? = encriptedImage.image
        if(ima == nil){
            self.alertd()
        }else {
            self.decryption()
        }
    }
}

