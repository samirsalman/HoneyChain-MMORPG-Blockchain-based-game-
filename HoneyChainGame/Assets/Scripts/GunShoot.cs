using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GunShoot : MonoBehaviour {

    [SerializeField] GameObject projectile;
    [SerializeField] float projectileSpeed = 500f;

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {

        if (Input.GetButtonDown("Fire1"))
        {
            GameObject projectileInstance;
            projectileInstance = Instantiate(projectile, transform.position, Quaternion.identity);


            //direziona il proiettile
            if (transform.parent.gameObject.transform.localScale.x > 0)
            {
                projectileInstance.GetComponent<Rigidbody2D>().AddForce(new Vector2(1, 0) * projectileSpeed);

            }
            else
            {
                projectileInstance.GetComponent<Rigidbody2D>().AddForce(new Vector2(-1, 0) * projectileSpeed);

            }
        }
    }
}
