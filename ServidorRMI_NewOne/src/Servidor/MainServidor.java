/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Servidor;

import java.net.InetAddress;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import conexion.connectionDrive;
import DAO.AuthDAO;
import DAO.ClienteDAO;
import DAO.EmpleadoDAO;
import DAO.PedidoDAO;
import DAO.ProductoDAO;
import DAO.ServicioDAO;

public class MainServidor {
    public static void main(String[] args) {
        try {
            connectionDrive.getEntityManager().close();
            System.out.println("JPA conectado a SQL Server exitosamente.");

            Registry registry = LocateRegistry.createRegistry(3239);
            
            registry.bind("authServicio", new AuthDAO());
            registry.bind("empleadoServicio", new EmpleadoDAO());
            registry.bind("clienteServicio", new ClienteDAO());
            registry.bind("productoServicio", new ProductoDAO());
            registry.bind("servicioCitaServicio", new ServicioDAO());
            registry.bind("pedidoServicio", new PedidoDAO());

            String dirIP = (InetAddress.getLocalHost()).toString();
            System.out.println("Servidor RMI escuchando en " + dirIP + " Puerto: 3239...");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}