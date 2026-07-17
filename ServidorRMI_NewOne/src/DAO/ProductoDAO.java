/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import Interfaces.IGestionProductosRemoto;
import entidades.Productos;
import conexion.connectionDrive;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;

public class ProductoDAO extends UnicastRemoteObject implements IGestionProductosRemoto {

    public ProductoDAO() throws RemoteException {
        super();
    }

    @Override
    public List<Productos> listarProductosActivos() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            List<Productos> lista = em.createQuery("SELECT p FROM Productos p WHERE p.estado = true", Productos.class).getResultList();
            for (Productos p : lista) {
                em.detach(p);
                p.setDetallePedidoList(null);
            }
            return lista;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public List<Productos> listarTodosProductos() throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            List<Productos> lista = em.createQuery("SELECT p FROM Productos p", Productos.class).getResultList();
            for (Productos p : lista) {
                em.detach(p);
                p.setDetallePedidoList(null);
            }
            return lista;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public Productos buscarProductoPorId(int idProducto) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        try {
            Productos p = em.find(Productos.class, idProducto);
            if (p != null) {
                em.detach(p);
                p.setDetallePedidoList(null);
            }
            return p;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean registrarProducto(Productos producto) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(producto);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean actualizarProducto(Productos producto) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(producto);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }

    @Override
    public boolean eliminarProducto(int idProducto) throws RemoteException {
        EntityManager em = connectionDrive.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Productos p = em.find(Productos.class, idProducto);
            if (p != null) {
                em.remove(p);
                tx.commit();
                return true;
            }
            return false;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }
}
