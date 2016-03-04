//
//  ViewController.swift
//  Encrypton
//
//  Created by Jesus Ruiz on 11/21/15.
//  Copyright © 2015 AkibaTeaParty. All rights reserved.
//
import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var decryptedText: UITextView!
    @IBOutlet weak var texttoEncrypt: UITextView!
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var encriptedImage: UIImageView!
    @IBOutlet weak var tabBar: UITabBar!
    
    let key:     [[Int]]    = [[3,1],
                               [5,2]]//Matriz llave
    let deKey:   [[Int]]    = [[2,-1],
                               [-5,3]]//Matriz Inversa de llave
    var A:       [[Int]]    = [[]]//Matrices
    var B:       [[Int]]    = [[]]//Resultado
    var toImage: [Int]      = []
    var temp:    [Int]      = []
    var imagePicker         = UIImagePickerController()
    var select:   Int       = 1//Selector para la imagen si 1 entonces original si 2 entonces encriptada
    var alphabet: [Character:Int] = [" ":0,"a":1,"b":2,"c":3,"d":4,"e":5,"f":6,"g":7,"h":8,"i":9,"j":10,"k":11,"l":12,"m":13,"n":14,"o":15,"p":16,"q":17,"r":18,"s":19,"t":20,"u":21,"v":22,"w":23,"x":24,"y":25,"z":26,"A":27,"B":28,"C":29,"D":30,"E":31,"F":32,"G":33,"H":34,"I":35,"J":36,"K":37,"L":38,"M":39,"N":40,"O":41,"P":42,"Q":43,"R":44,"S":45,"T":46,"U":47,"V":48,"W":49,"X":50,"Y":51,"Z":52,"ñ":53,"Ñ":54,"!":55,"?":56,"¡":57,"¿":58,"=":59,"@":60,"#":61,"$":62,"%":63,"^":64,"&":65,"*":66,"(":67,")":68,"-":69,"_":70,"[":71,"]":72,";":73,":":74,"/":75,"<":76,">":77,".":78,",":79,"|":80,"á":81,"é":82,"í":83,"ó":84,"ú":85,"Á":86,"É":87,"Í":88,"Ó":89,"Ú":90]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.texttoEncrypt.delegate = self
        //texttoEncrypt.textColor = UIColor.lightGrayColor()
        //originalImage.contentMode = UIViewContentMode.ScaleAspectFit
        //encriptedImage.contentMode = UIViewContentMode.ScaleAspectFit

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
        self.presentViewController(alert, animated: true, completion: nil)//ham
        
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
    @IBAction func Add(sender: UIButton){
        select = 1
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    //Borrar todo
    @IBAction func ClearAll(sender: UIButton){
        texttoEncrypt.text = "*Escribe el mensaje aqui*"
        texttoEncrypt.textColor = UIColor.lightGrayColor()
        decryptedText.text = "Mensaje desencriptado"
        encriptedImage.image = nil
        originalImage.image = nil
    }
    //Añadir imagen encriptada a la aplicacion
    @IBAction func AddEncrypted(sender: UIButton){
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
    //Acceder al diccionario
    func findKeyForChar(value: Character, dictionary: [Character:Int]) ->Int!
    {
        for (letter, number) in dictionary
        {
            if (letter == value)
            {
                return number
            }
        }
        
        return nil
    }
    func findKeyForValue(value: Int, dictionary: [Character:Int]) ->Character!
    {
        for (letter, number) in dictionary
        {
            if (number == value)
            {
                return letter
            }
        }
        
        return nil
    }
    //Acciones de encriptar
    func encryption(){
        
        var transform: [Int] = []
        var mov: Int = 0
        for character in (texttoEncrypt.text?.characters)!{//Leer el texto escrito y acomodarlo en array
            transform.append(findKeyForChar(character, dictionary: alphabet))
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
            decrypted.appendContentsOf(String(findKeyForValue(character, dictionary: alphabet)))
            
            //if (decrypted.containsString("≈")){
            if(character >= 91){
                break
            }
        }
        //let delimiter = "≈"//Delimitador para poder cortar las letras o palabras que saca del array y poner solo el mensaje
        //var token = decrypted.componentsSeparatedByString(delimiter)
        decryptedText.text = decrypted

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

