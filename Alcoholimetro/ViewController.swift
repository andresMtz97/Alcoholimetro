//
//  ViewController.swift
//  Alcoholimetro
//
//  Created by Ángel González on 24/02/23.
//

import UIKit
import CoreMotion
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    var targetView:UIView?
    var movingView:UIView?
    var refX: Double = 0
    var refY: Double = 0
    
    var motionManager = CMMotionManager()
    // para implementar la lógica "gamefication"
    var count = 0
    var Cronometro = UILabel()
    var timer:Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let W = self.view.bounds.size.width / 6
        let H = self.view.bounds.size.height / 6
        self.targetView = UIView(frame:CGRect(x:0,
                                              y:0,
                                              width: W,
                                              height: H))
        self.targetView!.backgroundColor = UIColor.purple
        self.targetView?.center = self.view.center
        self.view.addSubview(self.targetView!)
        self.movingView = UIView(frame:CGRect(x:0,
                                              y:100,
                                              width: W,
                                              height: H))
        self.movingView!.backgroundColor = UIColor.green
        self.view.addSubview(self.movingView!)
        refX = trunc((self.targetView?.frame.minX)!)
        refY = trunc((self.targetView?.frame.minY)!)
        iniciaAcelerometro()
        start()
        Cronometro.textColor = .white
        Cronometro.frame = CGRect(x:0,
                                y:40,
                                  width:self.view.frame.width,
                                height: 30)
        Cronometro.textAlignment = .right
        self.view.addSubview(Cronometro)
    }
    
    func iniciaAcelerometro() {
        let stepMoveFactor = 30.0
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { data, error in
            var rect = self.movingView!.frame
            // obtenemos la nueva posicion x/y de la vista y mutiplicamos por el factor de desplazamiento para que sea mas visible que la subview se mueve
            let movetoX  = rect.origin.x + CGFloat((data?.acceleration.x)! * stepMoveFactor)
            let movetoY  = rect.origin.y - CGFloat((data?.acceleration.y)! * stepMoveFactor)
            // calculamos que no se vaya a salir de la pantalla
            let maxX = self.view.frame.width - rect.width
            let maxY = self.view.frame.height - rect.height
            if movetoX > 0 && movetoX < maxX {
                rect.origin.x = movetoX
            }
            if ( movetoY > 0 && movetoY < maxY ) {
                rect.origin.y = movetoY
            }
            // ajutamos la nueva posicion de la vista
            self.movingView!.frame = rect
            // comprobamos si ya quedó en la posiciòn deseada (sobre la vista objetivo)
            if ((trunc(rect.minX) == self.refX ||
                 trunc(rect.minX) == self.refX - 1 ||
                 trunc(rect.minX) == self.refX + 1) &&
                (trunc(rect.minY) == self.refY ||
                 trunc(rect.minY) == self.refY - 1 ||
                 trunc(rect.minY) == self.refY + 1)) {
                self.motionManager.stopAccelerometerUpdates()
                self.endGame()
                self.Cronometro.text = "Timer"
            }
        }
        
        
    }
    
    func start() {
        self.count = 0
        timer = Timer.scheduledTimer(withTimeInterval:1.0, repeats:true, block: {
            _ in
            self.count += 1
            self.Cronometro.text = "Tiempo: \(self.count) segundos"
        })
    }
    
    func endGame() {
        self.timer?.invalidate()
        self.timer = nil
        let alert = UIAlertController(title: "Ganaste!", message: "Bien hecho! todavia puedes beber otra cerveza. Tiempo que tardaste \(self.count) quieres compartir tu score?", preferredStyle: .alert)
        let ac1 = UIAlertAction(title: "en mis redes", style: .default) { actionBtn in
            let imagen = UIImage(named: "beeeeer")
            let text = "Terminé el juego en \(self.count)"
            let avc = UIActivityViewController(activityItems: [imagen as Any], applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                avc.popoverPresentationController?.permittedArrowDirections = .any
                self.present(avc, animated: true)
            } else {
                self.present(avc, animated: true)
            }
        }
        let ac2 = UIAlertAction(title: "enviar mail", style: .cancel) { actionBtn in
            if MFMailComposeViewController.canSendMail() {
                let imagen = UIImage(named: "beeeeer")
                let mvc = MFMailComposeViewController()
                mvc.mailComposeDelegate = self
                mvc.setToRecipients(["arkantos890@gmail.com"])
                mvc.setMessageBody("<b>Terminé el juego en \(self.count)</b>", isHTML: true)
                if let imgData = imagen?.pngData() {
                    mvc.addAttachmentData(imgData, mimeType: "image/png", fileName: "beer.png")
                }
                mvc.setSubject("Gané en alcoholimetro game")
            }
        }
        let ac3 = UIAlertAction(title: "ahorita no joven", style: .destructive)
        alert.addAction(ac1)
        alert.addAction(ac2)
        self.present(alert, animated: true)
    }
}

